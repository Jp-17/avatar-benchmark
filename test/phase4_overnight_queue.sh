#!/bin/bash
set -u -o pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
LOG=$ROOT/test/phase4_overnight_queue.log
PID=$ROOT/test/phase4_overnight_queue.pid
UTILS=$ROOT/test/phase4_fullaudio_utils.sh
source "$UTILS"
mkdir -p "$ROOT/test"
: > "$LOG"
echo $$ > "$PID"
exec >> "$LOG" 2>&1
log() {
  printf '[%s] %s\n' "$(date '+%F %T')" "$*"
}
warn_disk() {
  local pct avail
  pct=$(disk_usage_pct)
  avail=$(disk_avail_h)
  if [ "$pct" -ge 97 ]; then
    log "磁盘告警：/root/autodl-tmp 使用率 ${pct}% ，可用 ${avail}"
  else
    log "磁盘状态：/root/autodl-tmp 使用率 ${pct}% ，可用 ${avail}"
  fi
}
wait_for_pattern() {
  local name="$1"
  local pattern="$2"
  while pgrep -f "$pattern" >/dev/null; do
    warn_disk
    log "$name 仍在运行，60 秒后继续检查"
    sleep 60
  done
}
run_or_wait() {
  local name="$1"
  local script="$2"
  local out1="$3"
  local out2="$4"
  local pattern="$5"
  local rc
  warn_disk
  if [ -s "$out1" ] && [ -s "$out2" ]; then
    log "$name 已有完整产物，跳过"
    return 0
  fi
  if pgrep -f "$pattern" >/dev/null; then
    log "$name 已在运行，等待结束"
    wait_for_pattern "$name" "$pattern"
  else
    log "启动 $name"
    bash "$script"
    rc=$?
    if [ "$rc" -eq 0 ]; then
      log "$name 返回成功"
    else
      log "$name 返回失败 rc=$rc；继续执行后续队列"
    fi
  fi
  if [ -s "$out1" ] && [ -s "$out2" ]; then
    log "$name 产物检查通过"
  else
    log "$name 产物仍不完整"
  fi
}
log 'Phase 4 夜间队列启动'
warn_disk
log '步骤 1/6：等待 OmniAvatar C_full_short 当前补跑结束'
wait_for_pattern 'OmniAvatar C_full_short' 'test/omniavatar/run_phase4_resume_cfull.sh|output/omniavatar_newphase4/logs/C_full_short.infer.txt'
if [ -s "$ROOT/output/omniavatar_newphase4/C_full_short.mp4" ]; then
  log 'OmniAvatar C_full_short 已完成'
else
  log 'OmniAvatar C_full_short 未发现成片，按用户要求继续后续夜间队列'
fi
run_or_wait 'LongCat-Video-Avatar Phase 4' "$ROOT/test/longcat-video-avatar/run_phase4_filtered.sh" "$ROOT/output/longcat_video_avatar_newphase4/C_half_short.mp4" "$ROOT/output/longcat_video_avatar_newphase4/C_full_short.mp4" 'test/longcat-video-avatar/run_phase4_filtered.sh|longcat_video_avatar_newphase4'
run_or_wait 'LiveAvatar 原始音频时长补跑' "$ROOT/test/liveavatar/run_phase4_fullaudio.sh" "$ROOT/output/liveavatar_newphase4_fullaudio/C_half_short.mp4" "$ROOT/output/liveavatar_newphase4_fullaudio/C_full_short.mp4" 'test/liveavatar/run_phase4_fullaudio.sh|liveavatar_newphase4_fullaudio'
run_or_wait 'Wan2.2-S2V 原始音频时长补跑' "$ROOT/test/wan2.2-s2v/run_phase4_fullaudio.sh" "$ROOT/output/wan22_s2v_newphase4_fullaudio/C_half_short.mp4" "$ROOT/output/wan22_s2v_newphase4_fullaudio/C_full_short.mp4" 'test/wan2.2-s2v/run_phase4_fullaudio.sh|wan22_s2v_newphase4_fullaudio'
run_or_wait 'LTX-2 原始音频时长补跑' "$ROOT/test/ltx2/run_phase4_fullaudio.sh" "$ROOT/output/ltx2_newphase4_fullaudio/C_half_short.mp4" "$ROOT/output/ltx2_newphase4_fullaudio/C_full_short.mp4" 'test/ltx2/run_phase4_fullaudio.sh|ltx2_newphase4_fullaudio'
run_or_wait 'FantasyTalking 原始音频时长补跑' "$ROOT/test/fantasy-talking/run_phase4_fullaudio.sh" "$ROOT/output/fantasy_talking_newphase4_fullaudio/C_half_short.mp4" "$ROOT/output/fantasy_talking_newphase4_fullaudio/C_full_short.mp4" 'test/fantasy-talking/run_phase4_fullaudio.sh|fantasy_talking_newphase4_fullaudio'
warn_disk
log 'Phase 4 夜间队列结束'
