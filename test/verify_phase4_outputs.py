#!/usr/bin/env python3
from __future__ import annotations
import argparse
import sys
from pathlib import Path

ROOT = Path('/root/autodl-tmp/avatar-benchmark')
MODEL_MAP = {
    'echomimic_v2': {'display': 'EchoMimic v2', 'dirs': ['output/echomimic_v2', 'output/echomimic_v2_newphase4']},
    'stableavatar': {'display': 'StableAvatar', 'dirs': ['output/stableavatar_newphase4']},
    'livetalk': {'display': 'LiveTalk', 'dirs': ['output/livetalk_newphase4']},
    'hallo3': {'display': 'Hallo3', 'dirs': ['output/hallo3_newphase4']},
    'ovi': {'display': 'Ovi', 'dirs': ['output/ovi_newphase4']},
    'mova': {'display': 'MOVA', 'dirs': ['output/mova_newphase4']},
    'wan22_s2v': {'display': 'Wan2.2-S2V', 'dirs': ['output/wan22_s2v_newphase4']},
    'liveavatar': {'display': 'LiveAvatar', 'dirs': ['output/liveavatar_newphase4']},
    'soulx_flashtalk': {'display': 'SoulX-FlashTalk', 'dirs': ['output/soulx_flashtalk_newphase4']},
    'ltx2': {'display': 'LTX-2', 'dirs': ['output/ltx2_newphase4']},
    'omniavatar': {'display': 'OmniAvatar', 'dirs': ['output/omniavatar_newphase4']},
    'fantasy_talking': {'display': 'FantasyTalking', 'dirs': ['output/fantasy_talking_newphase4']},
    'longlive': {'display': 'LongLive', 'dirs': ['output/longlive_newphase4']},
    'multitalk': {'display': 'MultiTalk', 'dirs': ['output/multitalk_newphase4']},
    'infinitetalk': {'display': 'InfiniteTalk', 'dirs': ['output/infinitetalk_newphase4']},
    'self_forcing': {'display': 'Self-Forcing', 'dirs': ['output/self_forcing_newphase4']},
}
DISPLAY_TO_KEY = {v['display']: k for k, v in MODEL_MAP.items()}


def pick_dir(model_key: str) -> Path | None:
    for rel in MODEL_MAP[model_key]['dirs']:
        path = ROOT / rel
        if path.exists():
            return path
    return None


def parse_results(results_path: Path):
    text = results_path.read_text(errors='ignore')
    items = []
    current = None
    for line in text.splitlines():
        if line.startswith('### '):
            if current:
                items.append(current)
            current = {'condition': line[4:].strip()}
        elif current and line.startswith('- '):
            key, _, value = line[2:].partition('：')
            if _:
                current[key.strip()] = value.strip()
    if current:
        items.append(current)
    return items


def verify_model(model_key: str):
    display = MODEL_MAP[model_key]['display']
    out_dir = pick_dir(model_key)
    errors = []
    notes = []
    if out_dir is None:
        errors.append('输出目录不存在')
        return display, None, [], errors, notes
    results_md = out_dir / 'results.md'
    if not results_md.exists():
        errors.append('results.md 不存在')
        return display, out_dir, [], errors, notes
    mp4s = sorted(p for p in out_dir.glob('*.mp4'))
    if not mp4s:
        errors.append('输出目录下没有 mp4 文件')
    items = parse_results(results_md)
    done_items = [item for item in items if 'done' in item.get('状态', '')]
    skipped_items = [item for item in items if 'skipped' in item.get('状态', '')]
    if items and not done_items and not skipped_items:
        notes.append('results.md 使用旧格式，已确认 results.md 与 mp4 文件存在')
    for item in done_items:
        out = item.get('输出路径', '').strip()
        if not out:
            errors.append(f"{item['condition']} 缺少输出路径记录")
            continue
        path = Path(out)
        if not path.exists():
            errors.append(f"{item['condition']} 输出文件不存在: {out}")
        elif path.stat().st_size <= 0:
            errors.append(f"{item['condition']} 输出文件为空: {out}")
    return display, out_dir, mp4s, errors, notes


def models_marked_completed():
    model_md = (ROOT / 'model.md').read_text(errors='ignore').splitlines()
    keys = []
    for line in model_md:
        if line.startswith('| ') and ('✅ 新4条件完成' in line or '✅ 支持子集完成' in line):
            parts = [p.strip() for p in line.split('|')]
            if len(parts) >= 10:
                key = DISPLAY_TO_KEY.get(parts[2])
                if key:
                    keys.append(key)
    return keys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('model_key', nargs='?')
    parser.add_argument('--all-completed', action='store_true')
    args = parser.parse_args()
    if args.all_completed:
        targets = models_marked_completed()
    elif args.model_key:
        if args.model_key not in MODEL_MAP:
            raise SystemExit(f'unknown model_key: {args.model_key}')
        targets = [args.model_key]
    else:
        raise SystemExit('need model_key or --all-completed')

    has_error = False
    for key in targets:
        display, out_dir, mp4s, errors, notes = verify_model(key)
        print(f'[{display}] dir={out_dir}')
        print(f'[{display}] mp4_count={len(mp4s)} files={[p.name for p in mp4s]}')
        for note in notes:
            print(f'[{display}] note={note}')
        if errors:
            has_error = True
            for err in errors:
                print(f'[{display}] ERROR: {err}')
        else:
            print(f'[{display}] OK')
    if has_error:
        sys.exit(1)

if __name__ == '__main__':
    main()
