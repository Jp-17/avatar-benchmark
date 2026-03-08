#!/bin/bash
set -euo pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
LOG_FILE=$ROOT/test/phase4_priority_switch.log
STATUS_FILE=$ROOT/test/phase4_priority_switch.status
cd "$ROOT"
log() {
  printf '%s %s\n' "$(date '+%F %T')" "$1" | tee -a "$LOG_FILE" > "$STATUS_FILE"
}
log "等待 MOVA 完成后切换到优先顺序队列"
while true; do
  status=$(cat test/phase4_queue.status 2>/dev/null || true)
  if echo "$status" | grep -q 'mova 已提交推送'; then
    log "检测到 MOVA 已提交推送，准备切队列"
    break
  fi
  if echo "$status" | grep -q '开始 wan22_s2v'; then
    log "检测到旧队列已开始 wan22_s2v，准备拦截并切优先队列"
    break
  fi
  if ! pgrep -f 'bash test/run_phase4_queue_resume.sh' >/dev/null 2>&1; then
    log "旧续跑队列已退出，直接启动优先队列"
    break
  fi
  sleep 5
done
pkill -f 'bash test/run_phase4_queue_resume.sh' || true
pkill -f 'bash test/wan2.2-s2v/run_phase4_filtered.sh' || true
sleep 2
if pgrep -f 'bash test/run_phase4_queue_priority.sh' >/dev/null 2>&1; then
  log "优先队列已存在，跳过重复启动"
  exit 0
fi
nohup bash test/run_phase4_queue_priority.sh >/tmp/phase4_queue_priority.nohup 2>&1 &
log "优先顺序队列已启动：LiveAvatar -> SoulX-FlashTalk -> Wan2.2-S2V -> FantasyTalking -> LTX-2 -> MultiTalk -> InfiniteTalk"
