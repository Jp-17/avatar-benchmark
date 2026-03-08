#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/postprocess_longcat.log
PID=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/postprocess_longcat.pid
: > "$LOG"
echo $$ > "$PID"
exec > >(tee -a "$LOG") 2>&1
RUN_PID_FILE=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/run_when_longcat_ready.pid
if [ -f "$RUN_PID_FILE" ]; then
  PID=$(cat "$RUN_PID_FILE")
  while ps -p "$PID" >/dev/null 2>&1; do
    printf "[%s] waiting runner pid=%s\n" "$(date "+%F %T")" "$PID"
    sleep 60
  done
fi
printf "[%s] === LONGCAT summary ===\n" "$(date "+%F %T")"
if [ -f test/longcat-video-avatar/output/longcat_video_avatar_minimal.log ]; then
  grep -n "runtime_seconds=" test/longcat-video-avatar/output/longcat_video_avatar_minimal.log || true
  tail -80 test/longcat-video-avatar/output/longcat_video_avatar_minimal.log || true
fi
find test/longcat-video-avatar/output -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.gif" \) -exec ls -lh {} \;
