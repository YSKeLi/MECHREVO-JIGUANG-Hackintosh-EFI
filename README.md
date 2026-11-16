# 机械革命极光 X 黑苹果 EFI · 发布仓库

发行版本：**v1.1**。同步日期：**2026-11-16**。基准为本机内置盘 EFI，系统 macOS 26.7.2（25G332）。公开版已清空三码，使用前请阅读下面的范围说明。

## 当前实测

| 项目 | 状态 |
| --- | --- |
| 硬件 | i7-13700HX / Intel UHD 770 / RTX 5060 Laptop / AX201 |
| 内屏 | 当前由 NVIDIA 驱动，2560×1600、180 Hz；混合模式内屏仍未修复 |
| NVIDIA | 系统实际加载四个组件均为 2.6.6；驱动不在 EFI 中 |
| 音频 | VoodooHDA 3.0.2；本轮确认设备枚举，未试听 |
| 核显 EFI 插件 | WhateverXe 0.7.0；系统图形组件需另外安装 |
| 隔空投送 | **已见双向成功，仍偶发失败**；ForbiddenItlwm 0.5.4-beta.2 + BTLEAdvFixup 0.9.1 |
| 蓝牙 | IntelBluetoothFirmware 2.5.0 + BlueToolFixup 2.7.3；IntelBTPatcher 禁用 |
| MechrevoControl | 按用户要求不打包，无对应加载项 |

10:50:05 日志确认电脑发送完成，10:50:40 确认电脑接收、解压和导入完成；另有两次设备发现超时和一次上传连接中断。详情见 [隔空投送实测](docs/隔空投送.md)。

接力、通用剪贴板、随航等没有在这轮测试中验证，不能从 AirDrop 成功推断它们可用。混合模式曾通过熄屏／唤醒点亮内屏，后来同样操作失效；11 月 11 日黑屏采集显示链路先训练成功、随后失锁，尚未证实唯一根因。旧实验过程保留，后续证据见 [内屏排查更新](docs/内屏排查更新-20261116.md)，当前状态以 [docs/当前状态.md](docs/当前状态.md) 为准。

## 使用范围

- 这不是完整系统备份，也不包含 Windows 引导。部署时保留原盘 `EFI/Microsoft` 和其他启动目录。
- `SystemSerialNumber`、`MLB`、`SystemUUID`、`ROM` 已清空，使用者需要填写自己独立的值。
- USB 映射和 ACPI 针对本机，其他机器需要核对适配。
- NVIDIA、核显系统图形栈及 VoodooHDA 位于 `/Library`，需单独配置，不能只复制这份 EFI 就视为安装完成。
- 不含 `apfs_aligned.efi`，对应配置禁用。这与实际启动验证的本机 EFI 有差异，未单独测试去除此项后的启动。
- 本次仅同步桌面 EFI 与相关文档。按用户要求，从桌面副本移除 MechrevoControl；没有修改本机运行的 EFI。

## 当前启动参数

```text
-igfxdvmt -v debug=0x100 keepsyms=1 -vi2c-force-polling ctrsmt=full -ibtcompatbeta revpatch=sbvmm,cpuname nvfb=1 nvaccel=1 nvfbheads=4 -nvkmsnosmooth amfi_get_out_of_my_way=0x1 amfi=0x80 ipc_control_port_options=0 gfxrst=4 revcpu=1 -allow3d -btleadv -itlawdlcoexprobe -itlawdliface -itlawdlnativeup -itlawdlcoexrx -itlawdlcoextx -itlawdlcoexmulti -itlawdlcoexdata -itlawdlmitx -itlawdlelicit -itlawdlcaps -itlawdlsvcmerge -itlawdlawsync itlawdlintcoal=4 -itlawdlcoexbatx -itlawdlcoexpeerpause -itlawdlcoexbatrace itlawdltxqueue=4096
```

这些参数是实机配置的快照。`-disablegfxfirmware` 已从当前配置移除；新加入的 AWDL 参数和适用范围见 [隔空投送](docs/隔空投送.md)。不要把本机实验参数当作其他机器的通用模板。

## 安装和验证

先保留完整 EFI 与系统驱动备份，再按 [安装步骤](docs/install.md) 准备。公开包中的空身份字段不应覆盖原机器已正常使用的值。

```bash
shasum -a 256 -c SHA256SUMS.txt
plutil -lint EFI/OC/config.plist
```

本次已检查文件完整性、plist 语法、启用路径与关键依赖顺序。公开包脱敏后没有单独启动实测；release 另有移除 apfs_aligned 的差异。填好本机配置后还需自行验证引导和各项功能。

修改系统 `/Library` 中的驱动时，需要按相应驱动安装方式处理内核集合，并核对 KDK 和系统 build；单纯更新 EFI 注入驱动与此不同。

## 文档

本版变更见 [v1.1 发行说明](CHANGELOG.md)。

| 文档 | 用途 |
| --- | --- |
| [当前状态](docs/当前状态.md) | 当前实际加载版本、实测结果和未验证范围 |
| [配置说明](docs/config-notes.md) | 当前 ACPI、驱动、参数与公开版差异 |
| [安装步骤](docs/install.md) | 安装范围、部署与 Windows 引导保留 |
| [问题排查](docs/troubleshooting.md) | 现象和对应处理 |
| [内屏排查更新](docs/内屏排查更新-20261116.md) | 后续回归、训练后失锁证据和仍待确认的原因 |
| [隔空投送](docs/隔空投送.md) | Intel AirDrop 版本、参数、成功与失败证据 |
| [核显驱动方法](docs/核显驱动方法.md) | 历史图形实验，保留原过程并注明适用日期 |
| [疑难排查记录](docs/疑难排查记录.md) | 历史问题、试验与判断依据 |
| [恢复步骤](docs/恢复步骤.txt) | 区分 EFI 回退与系统驱动 / AuxKC 恢复 |
| [第三方组件](THIRD_PARTY_LICENSES.md) | 组件版本、许可证和源码来源 |

## 许可与来源

本目录原有自编配置和文档的 MIT 许可保持不变。 第三方组件按各自许可证使用，未因本目录的许可证而重新授权。本次新增 AirDrop 组件的许可证副本位于 `licenses/`。

主要来源：Acidanthera、OpenIntelWireless、ForbiddenItlwm、WhateverXe、VoodooI2C、VoodooPS2、USBToolBox，以及系统中另行安装的 nullmoth NVIDIA 驱动。详见第三方清单。
