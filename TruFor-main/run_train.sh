#!/usr/bin/env bash
# ============================================================
# 在 WSL 内启动 TruFor 训练（RTX 3070 Laptop 8GB 适配配置）
#
# 用法（Windows 侧）：
#   wsl -d Ubuntu-22.04 -- bash -s < run_train.sh
# 或先进入 WSL 再执行：
#   bash /mnt/d/trufor_kaggle/TruFor-main/run_train.sh [--sync] [其它 train.py 参数]
#
#   --sync   先把 Windows 侧改过的代码同步到 WSL 内的副本 ~/TruFor 再训练
#   例：--sync TRAIN.END_EPOCH 20 VALID.FIRST_VALID True
# ============================================================
set -euo pipefail

EXP="${EXP:-trufor_ph2_imd}"
WIN_SRC="/mnt/d/trufor_kaggle/TruFor-main/TruFor-main"

if [ "${1:-}" = "--sync" ]; then
    shift
    echo ">>> 同步代码到 WSL 副本（保留 weights/ log/ 与预训练权重）"
    mkdir -p "$HOME/TruFor"
    rsync -a --delete --exclude weights/ --exclude log/ --exclude pretrained_models/ \
        "$WIN_SRC/" "$HOME/TruFor/TruFor-main/"
fi

source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda activate trufor

cd "$HOME/TruFor/TruFor-main/TruFor_train_test"
echo ">>> 实验: $EXP  GPU: $(/usr/lib/wsl/lib/nvidia-smi --query-gpu=name --format=csv,noheader)"
exec python -u train.py -exp "$EXP" "$@"
