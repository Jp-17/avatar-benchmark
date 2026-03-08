#!/bin/bash
set -euo pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
STATUS_FILE=$ROOT/test/phase4_queue.status
LOG_FILE=$ROOT/test/phase4_queue.log
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
wait_for_hallo3() {
  update_status "等待当前 Hallo3 任务结束"
  while pgrep -f 'output/hallo3_newphase4/logs/C_full_short.txt' >/dev/null 2>&1 || pgrep -f 'test/hallo3/run_phase4_filtered.sh' >/dev/null 2>&1; do
    sleep 30
  done
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
update_status "Phase4 顺序队列已启动"
wait_for_hallo3
update_status "Hallo3 已结束，开始回填与提交"
/root/miniconda3/bin/python test/update_phase4_docs.py hallo3
git add model.md progress.md output/hallo3_newphase4/config.json output/hallo3_newphase4/results.md test/hallo3/run_phase4_filtered.sh test/update_phase4_docs.py test/run_phase4_queue.sh
git commit -m "完成 Hallo3 新 Phase4 短时子集与记录"
git push origin master
update_status "Hallo3 已提交推送，继续 Ovi"
run_model ovi test/ovi/run_phase4_filtered.sh "完成 Ovi 新 Phase4 短时子集与记录" model.md progress.md output/ovi_newphase4/config.json output/ovi_newphase4/results.md test/ovi/run_phase4_filtered.sh test/update_phase4_docs.py
run_model mova test/mova/run_phase4_filtered.sh "完成 MOVA 新 Phase4 短时子集与记录" model.md progress.md output/mova_newphase4/config.json output/mova_newphase4/results.md test/mova/run_phase4_filtered.sh test/update_phase4_docs.py
run_model wan22_s2v test/wan2.2-s2v/run_phase4_filtered.sh "完成 Wan2.2-S2V 新 Phase4 短时子集与记录" model.md progress.md output/wan22_s2v_newphase4/config.json output/wan22_s2v_newphase4/results.md test/wan2.2-s2v/run_phase4_filtered.sh test/update_phase4_docs.py
run_model multitalk test/multitalk/run_phase4_filtered.sh "完成 MultiTalk 新 Phase4 短时子集与记录" model.md progress.md output/multitalk_newphase4/config.json output/multitalk_newphase4/results.md test/multitalk/run_phase4_filtered.sh test/update_phase4_docs.py
run_model infinitetalk test/infinitetalk/run_phase4_filtered.sh "完成 InfiniteTalk 新 Phase4 短时子集与记录" model.md progress.md output/infinitetalk_newphase4/config.json output/infinitetalk_newphase4/results.md test/infinitetalk/run_phase4_filtered.sh test/update_phase4_docs.py
update_status "队列阶段完成：Hallo3 / Ovi / MOVA / Wan2.2-S2V / MultiTalk / InfiniteTalk"
