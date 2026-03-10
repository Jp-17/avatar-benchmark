#!/bin/bash
set -u -o pipefail

ROOT=/root/autodl-tmp/avatar-benchmark
LOG=$ROOT/test/phase4_longaudio_queue.log
PID=$ROOT/test/phase4_longaudio_queue.pid
STATUS=$ROOT/test/phase4_longaudio_queue.status
UTILS=$ROOT/test/phase4_fullaudio_utils.sh
source "$UTILS"

mkdir -p "$ROOT/test"

if [ -f "$PID" ]; then
  old_pid=$(cat "$PID" 2>/dev/null || true)
  if [ -n "${old_pid:-}" ] && kill -0 "$old_pid" 2>/dev/null; then
    echo "phase4_longaudio_queue already running: pid=$old_pid"
    exit 1
  fi
fi

: > "$LOG"
echo $$ > "$PID"
echo "running" > "$STATUS"
exec >> "$LOG" 2>&1

log() {
  printf '[%s] %s\n' "$(date '+%F %T')" "$*"
}

cleanup() {
  rm -f "$PID"
}

trap cleanup EXIT

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

gpu_memory_used_mb() {
  local used
  used=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ' || true)
  case "$used" in
    ''|*[!0-9]*) used=999999 ;;
  esac
  echo "$used"
}

gpu_util_pct() {
  local util
  util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ' || true)
  case "$util" in
    ''|*[!0-9]*) util=999 ;;
  esac
  echo "$util"
}

gpu_compute_pids() {
  nvidia-smi --query-compute-apps=pid --format=csv,noheader 2>/dev/null | sed '/^[[:space:]]*$/d;/N\/A/d'
}

wait_for_gpu_idle() {
  local stable_checks=0
  local need_checks=3
  local sleep_secs=30
  local mem util pids
  while true; do
    mem=$(gpu_memory_used_mb)
    util=$(gpu_util_pct)
    pids=$(gpu_compute_pids)
    warn_disk
    if [ -z "$pids" ] && [ "$mem" -le 1024 ] && [ "$util" -le 5 ]; then
      stable_checks=$((stable_checks + 1))
      log "GPU 空闲检测通过 ${stable_checks}/${need_checks} 次（memory=${mem}MB, util=${util}%）"
      if [ "$stable_checks" -ge "$need_checks" ]; then
        log "GPU 已连续空闲，开始下一项长音频任务"
        return 0
      fi
    else
      stable_checks=0
      log "GPU 忙，继续等待（memory=${mem}MB, util=${util}%${pids:+, pids=$(echo "$pids" | tr '\n' ',' | sed 's/,$//')}）"
    fi
    sleep "$sleep_secs"
  done
}

run_step() {
  local name="$1"
  local script="$2"
  local rc
  log "准备执行：$name"
  wait_for_gpu_idle
  log "启动脚本：$script"
  bash "$script"
  rc=$?
  if [ "$rc" -eq 0 ]; then
    log "$name 执行完成"
  else
    log "$name 执行失败 rc=$rc；继续后续队列"
  fi
  return "$rc"
}

main() {
  local failures=0
  log "Phase 4 长音频顺序队列启动"
  log "执行顺序：InfiniteTalk -> LongCat -> MultiTalk -> OmniAvatar(C_full_long补跑)"

  run_step "OmniAvatar 长音频" "$ROOT/test/omniavatar/run_phase4_longaudio.sh" || failures=$((failures + 1))
  run_step "InfiniteTalk 长音频" "$ROOT/test/infinitetalk/run_phase4_longaudio.sh" || failures=$((failures + 1))
  run_step "LongCat-Video-Avatar 长音频" "$ROOT/test/longcat-video-avatar/run_phase4_longaudio.sh" || failures=$((failures + 1))
  run_step "MultiTalk 长音频" "$ROOT/test/multitalk/run_phase4_longaudio.sh" || failures=$((failures + 1))
  run_step "OmniAvatar 长音频（C_full_long 补跑）" "$ROOT/test/omniavatar/run_phase4_longaudio.sh" || failures=$((failures + 1))

  warn_disk
  if [ "$failures" -eq 0 ]; then
    echo "completed" > "$STATUS"
    log "Phase 4 长音频顺序队列完成"
    return 0
  fi

  echo "completed_with_failures:$failures" > "$STATUS"
  log "Phase 4 长音频顺序队列完成，但有 ${failures} 个步骤失败"
  return 1
}

main "$@"
