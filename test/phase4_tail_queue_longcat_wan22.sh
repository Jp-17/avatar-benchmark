#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/phase4_tail_queue_longcat_wan22.log
PID=/root/autodl-tmp/avatar-benchmark/test/phase4_tail_queue_longcat_wan22.pid
: > "$LOG"
echo $$ > "$PID"
exec > >(tee -a "$LOG") 2>&1
printf '[%s] wait OmniAvatar C_full_short\n' "$(date '+%F %T')"
while pgrep -f 'test/omniavatar/run_phase4_resume_cfull.sh|output/omniavatar_newphase4/logs/C_full_short.infer.txt' >/dev/null; do
  printf '[%s] OmniAvatar still running\n' "$(date '+%F %T')"
  sleep 60
done
if [ ! -s /root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/C_full_short.mp4 ]; then
  printf '[%s] OmniAvatar did not produce C_full_short.mp4; stop queue\n' "$(date '+%F %T')"
  exit 1
fi
printf '[%s] start LongCat-Video-Avatar Phase 4\n' "$(date '+%F %T')"
bash /root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/run_phase4_filtered.sh
printf '[%s] LongCat-Video-Avatar done\n' "$(date '+%F %T')"
printf '[%s] start Wan2.2-T2V Phase 4\n' "$(date '+%F %T')"
bash /root/autodl-tmp/avatar-benchmark/test/wan2.2-t2v-i2v/run_phase4_t2v_filtered.sh
printf '[%s] Wan2.2-T2V done\n' "$(date '+%F %T')"
