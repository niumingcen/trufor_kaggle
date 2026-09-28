import torch


def torch_load(path, **kwargs):
    # torch>=2.6 把 weights_only 默认值改成 True，而我们的 checkpoint 里带 numpy 标量（best_value）
    # 和 optimizer 状态，会被拒绝加载；老版本 torch（如 1.11）不认识 weights_only 参数，故按版本开关。
    version = tuple(int(v) for v in torch.__version__.split('+')[0].split('.')[:2])
    if version >= (2, 6):
        kwargs.setdefault('weights_only', False)
    return torch.load(path, **kwargs)
