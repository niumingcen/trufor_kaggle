#!/bin/bash
echo "=== key apt packages ==="
for p in build-essential python3-pip python3-dev git curl wget cmake pkg-config libgl1 libglib2.0-0 ffmpeg; do
  s=$(dpkg -s "$p" 2>/dev/null | grep -m1 '^Status' | awk '{print $4}')
  echo "$p: ${s:-not-installed}"
done
echo "=== python / conda ==="
python3 -V 2>&1
ls -d /opt/conda "$HOME"/miniconda3 "$HOME"/anaconda3 2>/dev/null || echo "no conda dir"
python3 -m pip --version 2>&1 | head -1
echo "=== gcc ==="
gcc --version 2>&1 | head -1 || echo "gcc MISSING"
echo "=== disk ==="
df -h / /mnt/d /mnt/c 2>/dev/null
echo "=== network (http code / seconds) ==="
curl -s -o /dev/null -w "pypi.org            : %{http_code} %{time_total}s\n" --max-time 10 https://pypi.org/simple/
curl -s -o /dev/null -w "tuna-pypi           : %{http_code} %{time_total}s\n" --max-time 10 https://pypi.tuna.tsinghua.edu.cn/simple/
curl -s -o /dev/null -w "repo.anaconda(mini) : %{http_code} %{time_total}s\n" --max-time 10 https://repo.anaconda.com/miniconda/
curl -s -o /dev/null -w "mirrors.tuna/anaconda: %{http_code} %{time_total}s\n" --max-time 10 https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/
curl -s -o /dev/null -w "github.com          : %{http_code} %{time_total}s\n" --max-time 10 https://github.com
curl -s -o /dev/null -w "archive.ubuntu.com  : %{http_code} %{time_total}s\n" --max-time 10 http://archive.ubuntu.com/ubuntu/
curl -s -o /dev/null -w "mirrors.ubuntu(tuna): %{http_code} %{time_total}s\n" --max-time 10 https://mirrors.tuna.tsinghua.edu.cn/ubuntu/
echo "=== nvidia wsl libs ==="
ls /usr/lib/wsl/lib/ 2>/dev/null | head -5
echo "=== done ==="
