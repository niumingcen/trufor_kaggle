from pathlib import Path
import os

project_root = Path(__file__).parent

# Specify where are the roots of the datasets.
# 每个数据集按顺序取第一个命中的来源：
#   1) 环境变量 TRUFOR_<KEY>（Kaggle / 集群 / 容器用它注入数据集挂载点）
#   2) WSL 内部副本（ext4，训练 IO 比 /mnt/d 的 9P 快数倍）
#   3) Windows 盘上的原始位置
# KEY 为大写目录名：FR / IMD / CA / TAMPCOCO / COMPRAISE
_CANDIDATES = {
    'FR'       : ['/home/mash1r0/datasets/FantasticReality', 'D:/FantasticReality', 'D:/trufor/FantasticReality'],
    'IMD'      : ['/home/mash1r0/datasets/IMD2020',          'D:/IMD2020', 'D:/trufor/IMD2020'],
    'CA'       : ['/home/mash1r0/datasets/CASIA2_revised',   'D:/CASIA2_revised', 'D:/trufor/CASIA2_revised'],
    'tampCOCO' : ['/home/mash1r0/datasets/tampCOCO',         'D:/tampCOCO', 'D:/trufor/tampCOCO'],
    'compRAISE': ['/home/mash1r0/datasets/compRAISE',        'D:/compRAISE', 'D:/trufor/compRAISE'],
}


def _first_existing(key):
    env = os.environ.get('TRUFOR_' + key.upper())
    if env:
        return env
    for p in _CANDIDATES[key]:
        if os.path.isdir(p):
            return p
    return f'path/to/{key}'


dataset_paths = {key: _first_existing(key) for key in _CANDIDATES}
