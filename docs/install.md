# 安装与同步步骤（2026-11-16）

这份 EFI 是机械革命极光 X 的配置快照，公开版已清除本机身份字段。它包含引导组件与 EFI 注入的驱动，不包含 `/Library` 中的 NVIDIA、核显图形栈和 VoodooHDA，也不是完整系统镜像。

## 1. 准备系统与恢复入口

历史安装流程使用 1401 工具创建安装介质，再安装系统图形驱动。本次同步没有重做全新安装，因此不保证当前安装工具的流程与历史版本一致。按所用安装工具的对应版本说明制作介质，并保留原来能够启动的 EFI。

BIOS 设置必须与本机配置匹配：关闭 Secure Boot；检查 CFG Lock、VT-d 和对应 OpenCore Quirks；显卡模式要与已经安装的图形驱动配套。当前本机处于独显驱动内屏的状态，180 Hz；混合模式的历史排查见 [核显驱动方法](核显驱动方法.md)。

## 2. 区分两种驱动安装位置

| 位置 | 本机当前组件 | 更新方式 |
| --- | --- | --- |
| EFI/OC/Kexts | Lilu、WhateverXe、ForbiddenItlwm、BTLEAdvFixup 等 | 更新 EFI 和 config，校验后重启 |
| /Library/Extensions、/Library/GPUBundles | NVIDIA 2.6.6、核显图形栈、VoodooHDA 3.0.2 | 由相应安装器处理，并核对 / 重建 AuxKC |

修改 `/Library` 中的驱动前，备份当前驱动和 AuxKC，确认系统版本与 KDK 匹配。单纯同步 EFI 不需要运行历史文档里的 AuxKC 重建命令。本次未重建内核集合。

## 3. 配置本机身份

公开版清空了以下值，使用者必须填入自己独立生成的值，不能把公开模板的空值覆盖到原来可用的本机身份上：

```text
PlatformInfo/Generic/SystemSerialNumber
PlatformInfo/Generic/MLB
PlatformInfo/Generic/SystemUUID
PlatformInfo/Generic/ROM
```

USB 映射和 ACPI 针对特定硬件，其他机器需要自行适配。MechrevoControl 已从本次桌面 EFI 副本移除。详见 [当前状态](当前状态.md)。

## 4. 部署前核对

1. 运行 `shasum -a 256 -c SHA256SUMS.txt` 核对公开目录文件。
2. 填写本机身份后，运行 `plutil -lint EFI/OC/config.plist`。这只是语法检查，不等于完整的 OpenCore 兼容验证。
3. 检查所有启用的驱动路径、依赖顺序和 MinKernel / MaxKernel。
4. 核对发行版关于 `apfs_aligned.efi` 的说明；它与本机测试配置可能有差异。
5. 将现有整个 EFI 复制到带日期的备份目录，确认内容可读和校验值一致。

## 5. 复制到 EFI 分区

先用 `diskutil list` 核实目标磁盘与 EFI 分区，再挂载对应分区。**不要照抄其他机器的 disk0s1 编号。**

将公开版 `EFI/BOOT` 和 `EFI/OC` 部署到目标 EFI 分区前，保留可用备份。使用独立临时目录准备并校验完整的 BOOT / OC，再替换对应目录。OpenCore.efi 与 BOOTx64.efi 要作为配套版本处理。

**保留原盘的 `EFI/Microsoft` 和其他系统引导目录。不要删除整个 EFI 根目录再复制公开包。** 公开包只包含 BOOT / OC，不会代替 Windows 启动文件。

完成后同步写入、卸载 EFI 分区，再手动重启。只有确有需要时才重置 NVRAM；不要把它当成每次复制后的固定步骤。

## 6. 重启后检查

```bash
kmutil showloaded --list-only | grep -E 'WhateverXe|ForbiddenItlwm|BTLEAdvFixup|nullmoth|VoodooHDA'
ifconfig awdl0
system_profiler SPDisplaysDataType SPAudioDataType
kmutil inspect
```

本次实测基线：NVIDIA 四个组件 2.6.6、VoodooHDA 3.0.2；ForbiddenItlwm 0.5.4、BTLEAdvFixup 0.9.1；内屏 2560×1600、180 Hz。不同显卡模式下的显示结果不能混用。

隔空投送要分别检查两个方向的实际完成情况，见 [隔空投送](隔空投送.md)。失败时参考 [恢复步骤](恢复步骤.txt)，按修改范围选择回退方式。
