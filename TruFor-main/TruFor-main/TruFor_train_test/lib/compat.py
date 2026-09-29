import sys
import importlib
import torch


def _numpy_core_alias():
    # numpy 2.x 把 numpy.core 改名为 numpy._core，用它保存的 checkpoint 在 numpy 1.x 上
    # 反序列化会报 ModuleNotFoundError: No module named 'numpy._core'（权重里的 best_value
    # 等标量是 numpy 类型）。补上旧名到新名的别名，跨 numpy 版本都能读。
    if 'numpy._core' in sys.modules:
        return
    try:
        importlib.import_module('numpy._core')
        return
    except ModuleNotFoundError:
        pass
    try:
        base = importlib.import_module('numpy.core')
    except ModuleNotFoundError:
        return
    sys.modules['numpy._core'] = base
    for sub in ('multiarray', 'numeric', 'numerictypes', 'overrides',
                '_multiarray_umath', 'umath', 'shape_base', 'fromnumeric'):
        try:
            sys.modules['numpy._core.' + sub] = importlib.import_module('numpy.core.' + sub)
        except ModuleNotFoundError:
            pass


def torch_load(path, **kwargs):
    # torch>=2.6 把 weights_only 默认值改成 True，而我们的 checkpoint 里带 numpy 标量（best_value）
    # 和 optimizer 状态，会被拒绝加载；老版本 torch（如 1.11）不认识 weights_only 参数，故按版本开关。
    version = tuple(int(v) for v in torch.__version__.split('+')[0].split('.')[:2])
    if version >= (2, 6):
        kwargs.setdefault('weights_only', False)
    _numpy_core_alias()
    return torch.load(path, **kwargs)
