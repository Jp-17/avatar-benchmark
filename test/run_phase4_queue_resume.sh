#!/bin/bash
set -u
ROOT=/root/autodl-tmp/avatar-benchmark
STATUS_FILE=$ROOT/test/phase4_queue.status
LOG_FILE=$ROOT/test/phase4_queue.log
cd "$ROOT"
update_status() {
  local msg="$1"
  printf '%s %s
' "$(date '+%F %T')" "$msg" | tee -a "$LOG_FILE" > "$STATUS_FILE"
}
commit_model() {
  local commit_msg="$1"
  shift
  git add "$@"
  if git diff --cached --quiet; then
    update_status "无新增变更，跳过提交"
    return 0
  fi
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
  if bash "$script_path"; then
    update_status "${model_key} 推理完成，回填文档"
    /root/miniconda3/bin/python test/update_phase4_docs.py "$model_key"
    commit_model "$commit_msg" "${add_files[@]}"
    update_status "${model_key} 已提交推送"
    return 0
  fi
  update_status "${model_key} 执行失败，已跳到下一个模型"
  return 1
}
update_status "Phase4 续跑队列已启动（从 MOVA 开始）"
run_model mova test/mova/run_phase4_filtered.sh "完成 MOVA 新 Phase4 短时子集与记录" model.md progress.md output/mova_newphase4/config.json output/mova_newphase4/results.md test/mova/run_phase4_filtered.sh test/update_phase4_docs.py test/run_phase4_queue_resume.sh test/phase4_monitor.sh
run_model wan22_s2v test/wan2.2-s2v/run_phase4_filtered.sh "完成 Wan2.2-S2V 新 Phase4 短时子集与记录" model.md progress.md output/wan22_s2v_newphase4/config.json output/wan22_s2v_newphase4/results.md test/wan2.2-s2v/run_phase4_filtered.sh test/update_phase4_docs.py test/run_phase4_queue_resume.sh test/phase4_monitor.sh
run_model multitalk test/multitalk/run_phase4_filtered.sh "完成 MultiTalk 新 Phase4 短时子集与记录" model.md progress.md output/multitalk_newphase4/config.json output/multitalk_newphase4/results.md test/multitalk/run_phase4_filtered.sh test/update_phase4_docs.py test/run_phase4_queue_resume.sh test/phase4_monitor.sh
run_model infinitetalk test/infinitetalk/run_phase4_filtered.sh "完成 InfiniteTalk 新 Phase4 短时子集与记录" model.md progress.md output/infinitetalk_newphase4/config.json output/infinitetalk_newphase4/results.md test/infinitetalk/run_phase4_filtered.sh test/update_phase4_docs.py test/run_phase4_queue_resume.sh test/phase4_monitor.sh
update_status "续跑队列已结束"
