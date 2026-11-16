# 第三方组件与许可证

本目录组件来自各自项目及本机匹配构建，按各自原始许可证使用。下方旧清单保留组件来源，当前版本和启用状态以 docs/config-notes.md 与实际 Info.plist 为准。

> 分发 GPL 类组件时，源码可从下方对应项目页获取（GPL 合规要求）。

---

## 一、历史组件清单与当前新增组件

### 基础 / 补丁注入

| 组件 | 版本 | 版权 | 许可证 | 项目 |
|---|---|---|---|---|
| Lilu | 1.7.3 | vit9696 | BSD-3-Clause | [acidanthera/Lilu](https://github.com/acidanthera/Lilu) |
| VirtualSMC | 1.3.9 | vit9696 | BSD-3-Clause | [acidanthera/VirtualSMC](https://github.com/acidanthera/VirtualSMC) |
| SMCBatteryManager | 1.3.9 | usrsse2 | BSD-3-Clause | ↑ 同上（插件） |
| SMCLightSensor | 1.3.9 | vit9696 | BSD-3-Clause | ↑ 同上（插件） |
| SMCProcessor | 1.3.9 | vit9696 | BSD-3-Clause | ↑ 同上（插件） |
| SMCSuperIO | 1.3.9 | joedm | BSD-3-Clause | ↑ 同上（插件） |
| AMFIPass | 1.4.1 | Dhinak G | 见项目页 | [DhinakG/AMFIPass](https://github.com/DhinakG/AMFIPass) |
| CpuTopologyRebuild | 2.0.2 | b00t0x | BSD-3-Clause | [b00t0x/CpuTopologyRebuild](https://github.com/b00t0x/CpuTopologyRebuild) |
| RestrictEvents | 1.1.7 | vit9696 | BSD-3-Clause | [acidanthera/RestrictEvents](https://github.com/acidanthera/RestrictEvents) |
| BrightnessKeys | 1.0.4 | vit9696 | BSD-3-Clause | [acidanthera/BrightnessKeys](https://github.com/acidanthera/BrightnessKeys) |
| NVMeFix | 1.1.4 | acidanthera | BSD-3-Clause | [acidanthera/NVMeFix](https://github.com/acidanthera/NVMeFix) |

### 核显（Intel UHD 770）

| 组件 | 版本 | 版权 | 许可证 | 项目 |
|---|---|---|---|---|
| **WhateverXe** | 0.7.0 | b00t0x | BSD-3-Clause | [b00t0x/WhateverXe](https://github.com/b00t0x/WhateverXe) |
| WhateverGreen | 1.7.2（**已禁用**） | vit9696 | BSD-3-Clause | [acidanthera/WhateverGreen](https://github.com/acidanthera/WhateverGreen) |

> ℹ️ 核显的系统层组件（`AppleIntelTGLGraphics.kext`、`AppleIntelTGLGraphicsFramebuffer.kext`、
> `AppleIntelTGLCompat.kext`）与 GPU bundle **不在本仓库**，需自行从
> [b00t0x/WhateverXe-Graphics](https://github.com/b00t0x/WhateverXe-Graphics) 的 payload 安装到 `/Library`。
> 详见 [docs/核显驱动方法.md](docs/核显驱动方法.md) 阶段 4。

### 音频

| 组件 | 版本 | 版权 | 许可证 | 项目 |
|---|---|---|---|---|
| AppleALC | 历史版本 1.9.8（**当前不打包**） | vit9696 | BSD-3-Clause | [acidanthera/AppleALC](https://github.com/acidanthera/AppleALC) |
| AppleALCU | 历史版本 1.9.8（**当前不打包**） | vit9696 | BSD-3-Clause | ↑ 同上 |
| SimpleHDA | 1.0.0（**未启用**） | laobamac | 见项目页 | [laobamac/SimpleHDA](https://github.com/laobamac/SimpleHDA) |

AppleALC 的不完整残留已从公开目录清理；AppleALCU 当前也未打包。上表保留历史来源归属，不代表这两个组件可直接启用。实际系统音频仍按当前状态页所列的 VoodooHDA 配置另行安装。

### 网络

| 组件 | 版本 | 版权 | 许可证 | 项目 |
|---|---|---|---|---|
| AirportItlwm | 2.4.0 | laobamac（基于 OpenIntelWireless） | **GPL-2.0** | [OpenIntelWireless/itlwm](https://github.com/OpenIntelWireless/itlwm) |
| RTL812xLucy | 1.1.100 | Laura Müller | 见项目页 | [Mieze/LucyRTL8125Ethernet](https://github.com/Mieze/LucyRTL8125Ethernet) 的衍生 |
| IntelBluetoothFirmware | 2.5.0 | 钟先耀（zxystd） | 见项目页 | [zxystd/IntelBluetoothFirmware](https://github.com/zxystd/IntelBluetoothFirmware) |
| IntelBTPatcher | 2.5.0 | zxystd | 见项目页 | ↑ 同上 |
| BlueToolFixup | 2.7.3 | acidanthera | BSD-3-Clause | [acidanthera/BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM) |

### 输入设备

| 组件 | 版本 | 版权 | 许可证 | 项目 |
|---|---|---|---|---|
| **VoodooI2C** | 2.9.1 | Alexandre Daoud | **GPL-3.0** | [VoodooI2C/VoodooI2C](https://github.com/VoodooI2C/VoodooI2C) |
| VoodooI2CHID | 1 | Alexandre Daoud | **GPL-3.0** | ↑ 同上 |
| VoodooGPIO / VoodooI2CServices / VoodooInput | — | Alexandre Daoud 等 | **GPL-3.0** | ↑ 同上（插件） |
| VoodooPS2Controller | 2.3.8 | acidanthera | **GPL-2.0** | [acidanthera/VoodooPS2](https://github.com/acidanthera/VoodooPS2) |
| VoodooPS2Keyboard / Mouse / Trackpad | 2.3.8 | acidanthera | **GPL-2.0** | ↑ 同上（插件） |

### USB

| 组件 | 版本 | 版权 | 许可证 | 项目 |
|---|---|---|---|---|
| USBToolBox | 1.2.0 | Dhinak G | MIT | [USBToolBox/tool](https://github.com/USBToolBox/tool) |
| UTBMap | 1.1 | 本机生成 | MIT | 由 USBToolBox 在本机导出 |
| XHCI-unsupported | 0.9.2 | acidanthera 社区 | 见项目页 | [OpenCore 社区](https://github.com/acidanthera) |

### 其他（历史清单；不在当前包中的条目不代表已打包）

| 组件 | 版本 | 版权 | 许可证 | 项目 |
|---|---|---|---|---|
| HighPointIOP / HighPointRR | — | HighPoint | 专有（随硬件提供） | 未启用，可删除 |

> 💡 `HighPointIOP.kext` / `HighPointRR.kext` 是历史遗留（给 HighPoint RAID 卡用的），
> 本机不需要，可以安全删除。它们没有出现在 `config.plist` 的启用列表里。

---

## 二、EFI 驱动（`EFI/OC/Drivers/`）

| 文件 | 版权 | 许可证 | 来源 |
|---|---|---|---|
| `HfsPlus.efi` | Apple Inc. | Apple 固件组件 | OpenCore 发行包附带 |
| `OpenRuntime.efi` | Acidanthera | BSD-3-Clause | [acidanthera/OpenCorePkg](https://github.com/acidanthera/OpenCorePkg) |
| `ResetNvramEntry.efi` | Acidanthera | BSD-3-Clause | ↑ 同上 |

### 关于 `apfs_aligned.efi`

本仓库**不包含** `apfs_aligned.efi`。

它是一个基于 Apple APFS 驱动修改的二进制，重新分发 Apple 专有二进制存在许可风险。
`config.plist` 中保留了对应条目但设为 `Enabled=False`，如需使用请自行从
[OCLP](https://github.com/dortania/OpenCore-Legacy-Patcher) 或
[OpenCorePkg](https://github.com/acidanthera/OpenCorePkg) 获取。

---

## 三、主题资源（`EFI/OC/Resources/`）

| 内容 | 版权 | 来源 |
|---|---|---|
| Font / Image / Label | Acidanthera | [acidanthera/OcBinaryData](https://github.com/acidanthera/OcBinaryData) |

部分 Label/Image 含 Apple 产品名称与图形，仅作菜单显示用途。

---

## 四、工具（`EFI/OC/Tools/`）

| 文件 | 版权 | 说明 |
|---|---|---|
| `NullMothSafe.efi` | [nullmoth](https://github.com/nullmoth/nvidia-macos-driver) | NVIDIA 驱动的安全模式启动工具 |

---

## 五、不包含在本仓库的组件

| 组件 | 原因 | 获取方式 |
|---|---|---|
| NVIDIA 驱动（NVRM / NVAccel / NVRMFB / NVRMAGDC / NMXAudio） | 装在 `/Library`，不在 EFI 内 | [nullmoth/nvidia-macos-driver](https://github.com/nullmoth/nvidia-macos-driver) 的 1401 应用 |
| 核显系统层组件（AppleIntelTGL* kext / GPUBundles） | 同上 | [b00t0x/WhateverXe-Graphics](https://github.com/b00t0x/WhateverXe-Graphics) payload |
| 内核集合（AuxKC） | 机器特定，不可跨机器共享 | 本机用 `kmutil create` 重建 |
| SMBIOS 三码 | 隐私，且每台机器必须唯一 | 用 OCAT / macserial 自行生成 |

---

## 六、许可证分布汇总

| 许可证 | 组件数 | 分发要求 |
|---|---|---|
| **BSD-3-Clause** | 15 | 保留版权声明与免责声明 |
| **GPL-3.0** | VoodooI2C 系列（5 个） | **必须提供源码** |
| **GPL-2.0** | VoodooPS2 系列（4 个）、AirportItlwm | **必须提供源码** |
| MIT | USBToolBox、UTBMap | 保留版权声明 |
| 见项目页 | AMFIPass、SimpleHDA、RTL812xLucy、IntelBluetoothFirmware、BTPatcher、XHCI-unsupported | 查看各自项目页 |

### GPL 合规说明

本仓库分发的 GPL 组件（VoodooI2C、VoodooPS2、AirportItlwm）**未做任何修改**，
源码可从上方对应项目页获取。发布前应按各组件许可证核对源码与分发材料；本清单本身不构成完整合规结论。

如原作者认为本仓库的分发方式不妥，请联系删除。

---

*同步更新：2026-11-16；旧组件清单源于 2026-11-07*

## 2026-11-16 新增 / 变更

| 组件 | 本次版本与状态 | 许可证与源码 |
| --- | --- | --- |
| ForbiddenItlwm | 0.5.4-beta.2 Tahoe，启用；内部 0.5.4 | GPL-2.0；[固定 tag 源码](https://github.com/retropineaple/ForbiddenItlwm/tree/v0.5.4-beta.2)，许可证副本 licenses/ForbiddenItlwm-GPL-2.0.txt |
| BTLEAdvFixup | 0.9.1 Tahoe，启用 | 来自同一 ForbiddenItlwm 发布与源码树，沿用项目许可证副本 |
| AirportItlwm | 2.4.0，保留但禁用 | 原组件许可证保持不变 |
| IntelBTPatcher | 2.5.0，保留但禁用 | 原组件许可证保持不变 |

旧列表的数量与状态只是历史清单，不作为当前启用组件统计。NVIDIA 和 VoodooHDA 安装在系统中，不随这份 EFI 打包。MechrevoControl 已按用户要求移除，不属于当前包。
