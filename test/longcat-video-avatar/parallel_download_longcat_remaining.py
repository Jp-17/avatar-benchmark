from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from urllib.request import Request, urlopen
import os
import shutil
import time

ROOT = Path('/root/autodl-tmp/avatar-benchmark')
LOG = ROOT / 'test/longcat-video-avatar/download_longcat_avatar_missing.log'
PID = ROOT / 'test/longcat-video-avatar/download_longcat_avatar_missing.pid'
FILES = [
    ('avatar_single/diffusion_pytorch_model-00004-of-00006.safetensors', 10707244640),
    ('avatar_single/diffusion_pytorch_model-00005-of-00006.safetensors', 10665318256),
    ('avatar_single/diffusion_pytorch_model-00006-of-00006.safetensors', 10048417104),
]
BASE_URL = 'https://hf-mirror.com/meituan-longcat/LongCat-Video-Avatar/resolve/main/'
WORKERS = 8
CHUNK_READ = 8 * 1024 * 1024
PID.write_text(str(os.getpid()))

def log(msg: str):
    line = f"[{time.strftime('%F %T')}] {msg}"
    print(line, flush=True)
    with LOG.open('a', encoding='utf-8') as f:
        f.write(line + '\n')

def download_part(url: str, start: int, end: int, part_path: Path):
    expected = end - start + 1
    if part_path.exists() and part_path.stat().st_size == expected:
        return
    if part_path.exists():
        part_path.unlink()
    headers = {'Range': f'bytes={start}-{end}', 'User-Agent': 'Mozilla/5.0'}
    last_error = None
    for attempt in range(1, 6):
        try:
            req = Request(url, headers=headers)
            with urlopen(req, timeout=120) as resp, part_path.open('wb') as out:
                while True:
                    buf = resp.read(CHUNK_READ)
                    if not buf:
                        break
                    out.write(buf)
            size = part_path.stat().st_size
            if size != expected:
                raise RuntimeError(f'part size mismatch expected={expected} actual={size}')
            return
        except Exception as exc:
            last_error = exc
            if part_path.exists():
                part_path.unlink()
            time.sleep(min(10 * attempt, 30))
    raise RuntimeError(f'failed range {start}-{end}: {last_error}')

for rel, total in FILES:
    out = ROOT / 'models/LongCat-Video/weights/LongCat-Video-Avatar' / rel
    out.parent.mkdir(parents=True, exist_ok=True)
    current = out.stat().st_size if out.exists() else 0
    if current == total:
        log(f'already complete {rel} size={current}')
        continue
    if current > total:
        raise RuntimeError(f'existing file larger than expected for {rel}: {current}>{total}')
    log(f'parallel resume {rel} current={current} total={total}')
    remaining = total - current
    chunk = (remaining + WORKERS - 1) // WORKERS
    part_dir = Path(str(out) + '.parts')
    shutil.rmtree(part_dir, ignore_errors=True)
    part_dir.mkdir(parents=True, exist_ok=True)
    futures = []
    with ThreadPoolExecutor(max_workers=WORKERS) as ex:
        for i in range(WORKERS):
            start = current + i * chunk
            if start >= total:
                continue
            end = min(total - 1, start + chunk - 1)
            part_path = part_dir / f'part_{i:02d}.bin'
            log(f'queue {rel} part_{i:02d} bytes={start}-{end}')
            futures.append(ex.submit(download_part, BASE_URL + rel, start, end, part_path))
        for fut in as_completed(futures):
            fut.result()
    with out.open('ab') as final:
        for i in range(WORKERS):
            part_path = part_dir / f'part_{i:02d}.bin'
            if not part_path.exists():
                continue
            with part_path.open('rb') as src:
                while True:
                    buf = src.read(CHUNK_READ)
                    if not buf:
                        break
                    final.write(buf)
            part_path.unlink()
    shutil.rmtree(part_dir, ignore_errors=True)
    final_size = out.stat().st_size
    if final_size != total:
        raise RuntimeError(f'final size mismatch for {rel}: expected={total} actual={final_size}')
    log(f'finished {rel} size={final_size}')

log('LongCat remaining shard download completed')
