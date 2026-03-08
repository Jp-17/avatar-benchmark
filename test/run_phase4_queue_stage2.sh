#!/bin/bash
set -euo pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
STATUS_FILE=$ROOT/test/phase4_queue_stage2.status
LOG_FILE=$ROOT/test/phase4_queue_stage2.log
cd "$ROOT"
update_status() {
  local msg="$1"
  printf '%s %s\n' "$(date '+%F %T')" "$msg" | tee -a "$LOG_FILE" > "$STATUS_FILE"
}
commit_model() {
  local model_key="$1"
  local commit_msg="$2"
  shift 2
  git add "$@"
  git commit -m "$commit_msg"
  git push origin master
}
run_model() {
  local model_key="$1"
  local script_path="$2"
  local commit_msg="$3"
  shift 3
  local add_files=("$@")
  update_status "开始 ${model_key}"
  bash "$script_path"
  update_status "${model_key} 推理完成，回填文档"
  /root/miniconda3/bin/python test/update_phase4_docs.py "$model_key"
  commit_model "$model_key" "$commit_msg" "${add_files[@]}"
  update_status "${model_key} 已提交推送"
}
update_status "等待主队列完成后接力 MultiTalk / InfiniteTalk"
while pgrep -f 'bash test/run_phase4_queue.sh' >/dev/null 2>&1; do
  sleep 30
 done
update_status "主队列已结束，开始 Stage2"
run_model multitalk test/multitalk/run_phase4_filtered.sh "完成 MultiTalk 新 Phase4 短时子集与记录" model.md progress.md output/multitalk_newphase4/config.json output/multitalk_newphase4/results.md test/multitalk/run_phase4_filtered.sh test/update_phase4_docs.py test/run_phase4_queue_stage2.sh test/phase4_monitor.sh test/run_phase4_queue.sh test/infinitetalk/run_phase4_filtered.sh
run_model infinitetalk test/infinitetalk/run_phase4_filtered.sh "完成 InfiniteTalk 新 Phase4 短时子集与记录" model.md progress.md output/infinitetalk_newphase4/config.json output/infinitetalk_newphase4/results.md test/infinitetalk/run_phase4_filtered.sh test/update_phase4_docs.py test/run_phase4_queue_stage2.sh test/phase4_monitor.sh test/run_phase4_queue.sh test/multitalk/run_phase4_filtered.sh
update_status "Stage2 完成：MultiTalk / InfiniteTalk"
