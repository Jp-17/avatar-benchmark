#!/bin/bash
# 串行执行 FlashHead Lite + Pro Phase 4
# Lite 完成后自动启动 Pro

LOGDIR=/root/autodl-tmp/avatar-benchmark/test/soulx-flashhead

echo "[$(date)] 开始串行执行 FlashHead Phase 4（Lite -> Pro）"

echo "[$(date)] === 启动 FlashHead Lite Phase 4 ==="
/root/autodl-tmp/avatar-benchmark/test/soulx-flashhead/run_phase4_lite.sh 2>&1 | tee $LOGDIR/run_phase4_lite.nohup.log
LITE_EXIT=$?

echo "[$(date)] Lite Phase 4 退出码: $LITE_EXIT"

if [ $LITE_EXIT -eq 0 ]; then
  echo "[$(date)] === 启动 FlashHead Pro Phase 4 ==="
  /root/autodl-tmp/avatar-benchmark/test/soulx-flashhead/run_phase4_pro.sh 2>&1 | tee $LOGDIR/run_phase4_pro.nohup.log
  PRO_EXIT=$?
  echo "[$(date)] Pro Phase 4 退出码: $PRO_EXIT"
else
  echo "[$(date)] Lite Phase 4 失败，跳过 Pro Phase 4"
fi

echo "[$(date)] FlashHead Phase 4 全部结束"
