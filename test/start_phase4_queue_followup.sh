#!/bin/bash
set -euo pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
LOG_FILE=$ROOT/test/phase4_followup_launcher.log
STATUS_FILE=$ROOT/test/phase4_followup_launcher.status
cd "$ROOT"
log() {
  printf '%s %s\n' "$(date '+%F %T')" "$1" | tee -a "$LOG_FILE" > "$STATUS_FILE"
}
log "等待当前优先队列结束后启动 OmniAvatar / LongLive / Self-Forcing"
while pgrep -f 'bash test/run_phase4_queue_priority.sh' >/dev/null 2>&1; do
  sleep 30
done
if pgrep -f 'bash test/run_phase4_queue_followup.sh' >/dev/null 2>&1; then
  log "follow-up 队列已存在，跳过重复启动"
  exit 0
fi
nohup bash test/run_phase4_queue_followup.sh >/tmp/phase4_queue_followup.nohup 2>&1 &
log "follow-up 队列已启动：OmniAvatar -> LongLive -> Self-Forcing"
