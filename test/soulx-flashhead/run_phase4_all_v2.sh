#!/bin/bash
# 串行执行 FlashHead Lite + Pro Phase 4（修复版）
set -euo pipefail

LOGDIR=/root/autodl-tmp/avatar-benchmark/test/soulx-flashhead

echo "[$(date)] 开始串行执行 FlashHead Phase 4（Lite -> Pro）"

echo "[$(date)] === 启动 FlashHead Lite Phase 4 ==="
/root/autodl-tmp/avatar-benchmark/test/soulx-flashhead/run_phase4_lite.sh > $LOGDIR/run_phase4_lite.nohup.log 2>&1
LITE_EXIT=$?
echo "[$(date)] Lite Phase 4 退出码: $LITE_EXIT"

echo "[$(date)] === 启动 FlashHead Pro Phase 4 ==="
/root/autodl-tmp/avatar-benchmark/test/soulx-flashhead/run_phase4_pro.sh > $LOGDIR/run_phase4_pro.nohup.log 2>&1
PRO_EXIT=$?
echo "[$(date)] Pro Phase 4 退出码: $PRO_EXIT"

echo "[$(date)] FlashHead Phase 4 全部结束"
