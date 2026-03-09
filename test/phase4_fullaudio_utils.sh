#!/bin/bash

audio_duration() {
  local file="$1"
  if command -v ffprobe >/dev/null 2>&1; then
    ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$file" 2>/dev/null | awk 'NR==1 {printf "%.3f", $1}'
    return
  fi
  if [[ "$file" == *.wav ]]; then
    /root/miniconda3/bin/python - "$file" <<'PY'
import sys, wave
with wave.open(sys.argv[1], 'rb') as w:
    print(f"{w.getnframes()/float(w.getframerate()):.3f}")
PY
    return
  fi
  ffmpeg -i "$file" 2>&1 | awk '/Duration:/ {gsub(/,/, "", $2); split($2, a, ":"); printf "%.3f", a[1]*3600+a[2]*60+a[3]; exit}'
}

video_duration() {
  local file="$1"
  if command -v ffprobe >/dev/null 2>&1; then
    ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$file" 2>/dev/null | awk 'NR==1 {printf "%.3f", $1}'
    return
  fi
  ffmpeg -i "$file" 2>&1 | awk '/Duration:/ {gsub(/,/, "", $2); split($2, a, ":"); printf "%.3f", a[1]*3600+a[2]*60+a[3]; exit}'
}

frames_for_duration() {
  /root/miniconda3/bin/python - "$1" "$2" "$3" <<'PY'
import math, sys

duration = float(sys.argv[1])
fps = float(sys.argv[2])
align = int(sys.argv[3])
frames = max(1, math.ceil(duration * fps - 1e-9))
if align > 1:
    frames = ((frames + align - 1) // align) * align
print(frames)
PY
}

frames_for_audio() {
  local audio="$1"
  local fps="$2"
  local align="${3:-1}"
  local duration
  duration=$(audio_duration "$audio")
  frames_for_duration "$duration" "$fps" "$align"
}

start_gpu_monitor() {
  local metrics_file="$1"
  (
    max=0
    while true; do
      used=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
      used=${used:-0}
      case "$used" in
        ''|*[!0-9]*) used=0 ;;
      esac
      if [ "$used" -gt "$max" ]; then
        max=$used
      fi
      echo "$max" > "$metrics_file"
      sleep 1
    done
  ) >/dev/null 2>&1 &
  echo $!
}

stop_gpu_monitor() {
  local pid="$1"
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
}

disk_usage_pct() {
  df -P /root/autodl-tmp | awk 'NR==2 {gsub(/%/, "", $5); print $5}'
}

disk_avail_h() {
  df -h /root/autodl-tmp | awk 'NR==2 {print $4}'
}
