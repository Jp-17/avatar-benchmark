#!/bin/bash
set -u
ROOT=/root/autodl-tmp/avatar-benchmark
STATUS_FILE=$ROOT/test/phase4_queue.status
LOG_FILE=$ROOT/test/phase4_queue.log
cd "$ROOT"
update_status() {
  local msg="$1"
  printf '%s %s\n' "$(date '+%F %T')" "$msg" | tee -a "$LOG_FILE" > "$STATUS_FILE"
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
    /root/miniconda3/bin/python test/verify_phase4_outputs.py "$model_key"
    update_status "${model_key} 推理完成，回填文档"
    /root/miniconda3/bin/python test/update_phase4_docs.py "$model_key"
    commit_model "$commit_msg" "${add_files[@]}"
    update_status "${model_key} 已提交推送"
    return 0
  fi
  update_status "${model_key} 执行失败，已跳到下一个模型"
  return 1
}
update_status "Phase4 follow-up 队列已启动"
COMMON_FILES=(test/omniavatar/run_phase4_filtered.sh test/longlive/run_phase4_filtered.sh test/self-forcing/run_phase4_filtered.sh test/run_phase4_queue_followup.sh test/start_phase4_queue_followup.sh test/update_phase4_docs.py test/verify_phase4_outputs.py test/phase4_output_audit_watch.sh)
run_model omniavatar test/omniavatar/run_phase4_filtered.sh "完成 OmniAvatar 新 Phase4 短时子集与记录" model.md progress.md output/omniavatar_newphase4/config.json output/omniavatar_newphase4/results.md "${COMMON_FILES[@]}"
run_model longlive test/longlive/run_phase4_filtered.sh "完成 LongLive 新 Phase4 短时子集与记录" model.md progress.md output/longlive_newphase4/config.json output/longlive_newphase4/results.md "${COMMON_FILES[@]}"
run_model self_forcing test/self-forcing/run_phase4_filtered.sh "完成 Self-Forcing 新 Phase4 短时子集与记录" model.md progress.md output/self_forcing_newphase4/config.json output/self_forcing_newphase4/results.md "${COMMON_FILES[@]}"
update_status "follow-up 队列已结束"
