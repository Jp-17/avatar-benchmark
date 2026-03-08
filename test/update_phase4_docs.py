#!/usr/bin/env python3
from __future__ import annotations
import argparse
import re
from datetime import datetime
from pathlib import Path

ROOT = Path('/root/autodl-tmp/avatar-benchmark')

MODEL_MAP = {
    'livetalk': {
        'display': 'LiveTalk',
        'row_prefix': '| 3 | LiveTalk |',
        'output_dir': 'output/livetalk_newphase4',
        'script': 'test/livetalk/run_phase4_filtered.sh',
        'section_match': r'#### LiveTalk（.*?）\n\n\| Condition \| 状态 \|.*?(?=\n#### |\Z)',
        'subset': False,
    },
    'hallo3': {
        'display': 'Hallo3',
        'row_prefix': '| 4 | Hallo3 |',
        'output_dir': 'output/hallo3_newphase4',
        'script': 'test/hallo3/run_phase4_filtered.sh',
        'section_match': r'#### Hallo3（.*?）\n\n\| Condition \| 状态 \|.*?(?=\n#### |\Z)',
        'subset': True,
    },
    'ovi': {
        'display': 'Ovi',
        'row_prefix': '| 5 | Ovi |',
        'output_dir': 'output/ovi_newphase4',
        'script': 'test/ovi/run_phase4_filtered.sh',
        'section_match': r'#### Ovi（.*?）\n\n\| Condition \| 状态 \|.*?(?=\n#### |\Z)',
        'subset': True,
    },
    'mova': {
        'display': 'MOVA',
        'row_prefix': '| 6 | MOVA |',
        'output_dir': 'output/mova_newphase4',
        'script': 'test/mova/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
    'wan22_s2v': {
        'display': 'Wan2.2-S2V',
        'row_prefix': '| 7 | Wan2.2-S2V |',
        'output_dir': 'output/wan22_s2v_newphase4',
        'script': 'test/wan2.2-s2v/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
    'liveavatar': {
        'display': 'LiveAvatar',
        'row_prefix': '| 8 | LiveAvatar |',
        'output_dir': 'output/liveavatar_newphase4',
        'script': 'test/liveavatar/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
    'soulx_flashtalk': {
        'display': 'SoulX-FlashTalk',
        'row_prefix': '| 9 | SoulX-FlashTalk |',
        'output_dir': 'output/soulx_flashtalk_newphase4',
        'script': 'test/soulx-flashtalk/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
    'ltx2': {
        'display': 'LTX-2',
        'row_prefix': '| 10 | LTX-2 |',
        'output_dir': 'output/ltx2_newphase4',
        'script': 'test/ltx2/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
    'omniavatar': {
        'display': 'OmniAvatar',
        'row_prefix': '| 11 | OmniAvatar |',
        'output_dir': 'output/omniavatar_newphase4',
        'script': 'test/omniavatar/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
    'fantasy_talking': {
        'display': 'FantasyTalking',
        'row_prefix': '| 12 | FantasyTalking |',
        'output_dir': 'output/fantasy_talking_newphase4',
        'script': 'test/fantasy-talking/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
    'longlive': {
        'display': 'LongLive',
        'row_prefix': '| 16 | LongLive |',
        'output_dir': 'output/longlive_newphase4',
        'script': 'test/longlive/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
    'multitalk': {
        'display': 'MultiTalk',
        'row_prefix': '| 18 | MultiTalk |',
        'output_dir': 'output/multitalk_newphase4',
        'script': 'test/multitalk/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
    'infinitetalk': {
        'display': 'InfiniteTalk',
        'row_prefix': '| 19 | InfiniteTalk |',
        'output_dir': 'output/infinitetalk_newphase4',
        'script': 'test/infinitetalk/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
    'self_forcing': {
        'display': 'Self-Forcing',
        'row_prefix': '| 20 | Self-Forcing |',
        'output_dir': 'output/self_forcing_newphase4',
        'script': 'test/self-forcing/run_phase4_filtered.sh',
        'section_match': None,
        'subset': True,
    },
}


def parse_results(path: Path):
    text = path.read_text()
    sections = []
    current = None
    for line in text.splitlines():
        if line.startswith('### '):
            if current:
                sections.append(current)
            current = {'condition': line[4:].strip()}
        elif current and line.startswith('- '):
            key, _, value = line[2:].partition('：')
            if _:
                current[key.strip()] = value.strip()
    if current:
        sections.append(current)
    return sections


def update_model_row(model_text: str, prefix: str, status: str, remark: str) -> str:
    lines = model_text.splitlines()
    for i, line in enumerate(lines):
        if line.startswith(prefix):
            parts = line.split('|')
            if len(parts) >= 12:
                parts[9] = f' {status} '
                parts[10] = f' {remark} '
                lines[i] = '|'.join(parts)
            break
    return '\n'.join(lines) + '\n'


def build_remark(done, skipped, full: bool):
    done_text = '/'.join(done) if done else '无'
    if full:
        return f'已完成新 Phase 4 的 {done_text}；results.md 已记录显存峰值与生成时间'
    skip_text = '/'.join(skipped) if skipped else '无'
    return f'已完成新 Phase 4 的 {done_text}；{skip_text} 按最小测试稳定路径跳过；results.md 已记录显存峰值与生成时间'


def build_section(display: str, items):
    title = f'#### {display}（支持子集完成）'
    lines = [title, '', '| Condition | 状态 | 输出文件 | 显存峰值 | 推理时间 | 备注 |', '|-----------|------|---------|---------|---------|------|']
    for item in items:
        cond = item['condition']
        status = item.get('状态', '')
        if 'skipped' in status:
            lines.append(f"| {cond} | {status} | - | - | - | {item.get('跳过原因', '')} |")
        else:
            lines.append(f"| {cond} | {status} | {item.get('输出路径', '-')} | {item.get('显存峰值', '-')} | {item.get('推理生成时间', '-')} | {item.get('失败经验与解决方法', '')} |")
    return '\n'.join(lines)


def replace_or_append_section(model_text: str, meta: dict, section_text: str) -> str:
    pattern = meta.get('section_match')
    if pattern and re.search(pattern, model_text, flags=re.S):
        return re.sub(pattern, section_text, model_text, count=1, flags=re.S)
    marker = '### Phase 4 批推理执行状态\n'
    idx = model_text.find(marker)
    if idx == -1:
        return model_text + '\n\n' + section_text + '\n'
    insert_at = model_text.find('\n### ', idx + len(marker))
    if insert_at == -1:
        insert_at = len(model_text)
    return model_text[:insert_at].rstrip() + '\n\n' + section_text + '\n\n' + model_text[insert_at:].lstrip('\n')


def append_progress(meta: dict, items):
    progress = ROOT / 'progress.md'
    now = datetime.now().strftime('%Y-%m-%d %H:%M')
    done = [i['condition'] for i in items if 'skipped' not in i.get('状态', '')]
    skipped = [i['condition'] for i in items if 'skipped' in i.get('状态', '')]
    result_lines = []
    for item in items:
        cond = item['condition']
        if 'skipped' in item.get('状态', ''):
            result_lines.append(f"{cond} 跳过（{item.get('跳过原因', '')}）")
        else:
            result_lines.append(f"{cond} {item.get('显存峰值', '-')} / {item.get('推理生成时间', '-')} / {item.get('输出路径', '-')}")
    issue_lines = []
    for item in items:
        msg = item.get('失败经验与解决方法', '')
        if msg and '无新增问题' not in msg and '沿用 ' not in msg:
            issue_lines.append(msg)
    if not issue_lines:
        issue_lines = ['无新增问题，沿用该模型在 Phase 2 最小素材测试中已验证的稳定路径。']
    entry = f"\n\n## {now}\n\n### 任务内容\n1. 按 plan.md Phase 4 的 filtered 条件完成 {meta['display']} 的正式推理。\n2. 参考 {meta['script']} 与对应 test.md 中的最小素材测试经验，沿用已验证命令、环境变量、依赖补丁与避坑方案。\n3. 按最新 4.2 规范补充 {meta['output_dir']}/results.md，记录每个 Condition 的命令、素材、显存峰值、推理生成时间与输出路径。\n\n### 结果与效果\n1. {meta['display']} 已完成支持子集的 Phase 4 条件，完成项：{'、'.join(done) if done else '无'}；跳过项：{'、'.join(skipped) if skipped else '无'}。\n2. 结果明细：{'；'.join(result_lines)}。\n3. model.md 已同步更新当前模型的 Phase 4 状态，后续可直接按同一记录格式推进下一个模型。\n\n### 遇到的问题与解决方法\n" + '\n'.join(f'{i+1}. {msg}' for i, msg in enumerate(issue_lines))
    progress.write_text(progress.read_text() + entry)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('model_key', choices=MODEL_MAP)
    args = parser.parse_args()
    meta = MODEL_MAP[args.model_key]
    results_path = ROOT / meta['output_dir'] / 'results.md'
    items = parse_results(results_path)
    done = [i['condition'] for i in items if 'skipped' not in i.get('状态', '')]
    skipped = [i['condition'] for i in items if 'skipped' in i.get('状态', '')]
    full = (not meta['subset']) and len(done) == 4
    status = '✅ 新4条件完成' if full else '✅ 支持子集完成'
    remark = build_remark(done, skipped, full)

    model_path = ROOT / 'model.md'
    model_text = model_path.read_text()
    model_text = update_model_row(model_text, meta['row_prefix'], status, remark)
    section_text = build_section(meta['display'], items)
    model_text = replace_or_append_section(model_text, meta, section_text)
    model_path.write_text(model_text)

    append_progress(meta, items)

if __name__ == '__main__':
    main()
