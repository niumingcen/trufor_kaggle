#!/usr/bin/env bash
# ============================================================
# TruFor 训练环境搭建脚本（在 WSL2 / Ubuntu 22.04 内执行）
#
# 用法：
#   1) 在 Windows 侧：wsl -d Ubuntu-22.04
#   2) 在 WSL 内：    bash /mnt/d/trufor/TruFor-main/setup_wsl_env.sh
#   3) 激活环境：     source ~/miniconda3/etc/profile.d/conda.sh && conda activate trufor
#
# 注意：sudo 会要求输入 WSL 用户密码；数据集需自行下载（见文件末尾提示）
# ============================================================
set -euo pipefail

ENV_NAME="${ENV_NAME:-trufor}"
PY_VER="${PY_VER:-3.7}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> [1/6] 安装系统级依赖（需要 sudo 密码）"
sudo apt-get update -y
sudo apt-get install -y \
    build-essential python3-dev cmake pkg-config \
    libjpeg-dev zlib1g-dev \
    libgl1 libglib2.0-0 libsm6 libxrender1 ffmpeg

echo ">>> [2/6] 安装 Miniconda（python3.7 版）"
if [ ! -d "$HOME/miniconda3" ]; then
    wget -q -O /tmp/miniconda.sh \
        https://repo.anaconda.com/miniconda/Miniconda3-py37_4.12.0-Linux-x86_64.sh
    bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
fi
# shellcheck disable=SC1091
source "$HOME/miniconda3/etc/profile.d/conda.sh"

echo ">>> [3/6] 创建 conda 环境 $ENV_NAME (python=$PY_VER)"
if ! conda env list | grep -qE "^${ENV_NAME}\\s"; then
    conda create -y -n "$ENV_NAME" python="$PY_VER" pip
fi
conda activate "$ENV_NAME"
python -m pip install -U pip setuptools wheel
# pypi 官方直连较慢，换清华源；torch 的 +cu113 走官方 extra index
python -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

echo ">>> [4/6] 安装 PyTorch 1.11.0 + CUDA 11.3"
pip install \
    torch==1.11.0+cu113 \
    torchvision==0.12.0+cu113 \
    torchaudio==0.11.0+cu113 \
    -f https://download.pytorch.org/whl/cu113/torch_stable.html

echo ">>> [5/6] 安装其余 Python 依赖"
pip install -r "$HERE/requirements_min.txt"

echo ">>> [6/6] 校验 GPU 是否可用"
python - <<'PY'
import torch
print("torch      :", torch.__version__)
print("cuda avail :", torch.cuda.is_available())
if torch.cuda.is_available():
    print("device     :", torch.cuda.get_device_name(0))
    x = torch.randn(256, 256, device="cuda")
    print("matmul ok  :", (x @ x).sum().item() > 0)
PY

cat <<'TIP'

============================================================
环境就绪。训练前还需要：

1) 数据集
   - IMD2020 本机已有：D:\trufor\IMD2020（585 MB，414 组图 + mask）
     建议先拷进 WSL 内部再用（/mnt/d 走 9P 协议，IO 慢好几倍）：
       mkdir -p ~/datasets && cp -r /mnt/d/trufor/IMD2020 ~/datasets/
   - 其余（FantasticReality / CASIA2 revised / tampCOCO / compRAISE）本机没有，需下载；
     WSL 内 github / Google Drive 直连不通，建议在 Windows 侧下载后放进 ~/datasets/
   - 先用单数据集跑通：DATASET.TRAIN 只留 [IMD]

2) 改 TruFor_train_test/project_config.py 里的 dataset_paths 指向实际路径

3) 显存：RTX 3070 Laptop 8GB 装不下官方 batch=18（那是 32GB V100 的配置）
     python train.py -exp trufor_ph2 TRAIN.BATCH_SIZE_PER_GPU 2 CUDNN.WORKERS 8
============================================================
TIP
