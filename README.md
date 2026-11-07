# Hackintosh EFI — MECHREVO 极光 (JIGUANG) / i7-13700HX / macOS 26 Tahoe

OpenCore 引导配置，适用于 **机械革命 极光（JIGUANG）系列笔记本**，运行 **macOS 26 (Tahoe)**。
核显由 **WhateverXe** 驱动，独显 RTX 5060 由 [**nullmoth/nvidia-macos-driver**](https://github.com/nullmoth/nvidia-macos-driver) 驱动。

> **这是一个"可工作的配置"，不是即插即用的成品。**
> 必读章节：[使用前必读](#使用前必读) —— 尤其是 **三码**、**KDK** 和 **独显驱动** 三节。

---

## 目录

- [硬件配置](#硬件配置)
- [软件版本](#软件版本)
- [boot-args](#boot-args)
- [使用前必读](#使用前必读)
- [安装流程](#安装流程)
- [显卡说明](#显卡说明)
- [已知问题](#已知问题)
- [不可用功能](#不可用功能)
- [目录结构](#目录结构)
- [文档索引](#文档索引)
- [常见问题](#常见问题)
- [许可与致谢](#许可与致谢)

---

## 硬件配置

| 部件 | 型号 | 状态 | 说明 |
|---|---|---|---|
| 整机 | MECHREVO 极光系列（JIGUANG） | — | 同模具：GM6AR57C |
| 主板 | MECHREVO KUANGSHI-JIGUANG（Intel HM770） | — | — |
| CPU | Intel Core i7-13700HX | ✅ 原生 | 8 P-core + 8 E-core，24 线程 |
| 核显 | Intel UHD Graphics 770 | ⚠️ 见[显卡说明](#显卡说明) | `8086:4688`，32 EU |
| 独显 | NVIDIA GeForce RTX 5060 Laptop 8 GB | ✅ | `10DE:2D19`，Metal 3 |
| 内存 | Micron 32 GB DDR5-4800 | ✅ | — |
| 存储 | Kingston OM8TAP41024K1-A00 1 TB NVMe | ✅ | NVMeFix |
| 内屏 | BOE NE160QDM-NYL | ✅ | 2560×1600，最高 180 Hz |
| 无线 | Intel Wi-Fi 6 AX201 | ⚠️ | 可用，但**无 AWDL** |
| 有线 | Realtek 2.5GbE | ✅ | RTL812xLucy |
| 音频 | Conexant + NVIDIA HDA | ✅ | 由驱动包的 NMXAudio 驱动 |
| 蓝牙 | Intel（`THIRD_PARTY_DONGLE`） | ✅ | 需 `-ibtcompatbeta` |
| 触控板 | I2C HID | ✅ | VoodooI2C + VoodooPS2 |
| SMBIOS | MacBookPro16,2 | — | 配合 `revpatch=sbvmm` |

## 软件版本

| 组件 | 版本 | 位置 |
|---|---|---|
| macOS | 26.7.2 (25G332) | — |
| OpenCore | 见 `EFI/OC/OpenCore.efi` | EFI |
| Lilu | 1.7.3 | EFI |
| WhateverXe | 0.7.0 | EFI |
| WhateverGreen | — | **已禁用**（由 WhateverXe 取代） |
| VirtualSMC | 1.3.9 | EFI |
| AirportItlwm | 2.4.0 | EFI |
| AMFIPass | 1.4.1 | EFI |
| RestrictEvents | 1.1.7 | EFI |
| NVMeFix | 1.1.4 | EFI |
| CpuTopologyRebuild | 2.0.2 | EFI |
| NVIDIA 驱动 | 2.7.1 | `/Library`（**不在 EFI 内**） |
| KDK | 26.7.2 build 25G332 | `/Library/Developer/KDKs` |

## boot-args

```
-igfxdvmt -v debug=0x100 keepsyms=1 -vi2c-force-polling ctrsmt=full -ibtcompatbeta
revpatch=sbvmm,cpuname nvfb=1 nvaccel=1 nvfbheads=4 -nvkmsnosmooth
amfi_get_out_of_my_way=0x1 amfi=0x80 ipc_control_port_options=0 gfxrst=4 revcpu=1
-allow3d -disablegfxfirmware
```

| 参数 | 作用 | 稳定后可去掉？ |
|---|---|---|
| `-igfxdvmt` | WhateverXe：忽略固件 DVMT，使用补丁值 | 否 |
| `-v debug=0x100 keepsyms=1` | 详细启动日志 + 保留符号 | **是**（调试用） |
| `-vi2c-force-polling` | VoodooI2C 强制轮询，解决触控板中断丢失 | 否 |
| `ctrsmt=full` | 开启全部 SMT（超线程） | 否 |
| `-ibtcompatbeta` | 蓝牙兼容模式（13 代 CPU 必需） | 否 |
| `revpatch=sbvmm,cpuname` | RestrictEvents：绕过机型限制 + 显示真实 CPU 名 | 否 |
| `revcpu=1` | RestrictEvents：启用 CPU 名称补丁 | 否 |
| `nvfb=1 nvaccel=1 nvfbheads=4` | nullmoth 驱动：帧缓冲 / 加速 / 4 个显示头 | 否 |
| `-nvkmsnosmooth` | 关闭 NVKMS 平滑模式 | 否 |
| `amfi_get_out_of_my_way=0x1 amfi=0x80` | 关闭 AMFI，加载未签名 kext | 否 |
| `ipc_control_port_options=0` | 修正 IPC 端口行为 | 否 |
| `gfxrst=4` | 图形复位策略 | 否 |
| `-allow3d` | 允许 3D 加速 | 否 |
| `-disablegfxfirmware` | 禁止加载 GuC 固件 | 否 |

---

## 使用前必读

### 1. 三码必须自己生成

`config.plist` 中以下字段**已清空**：

```
PlatformInfo/Generic/SystemSerialNumber
PlatformInfo/Generic/MLB
PlatformInfo/Generic/SystemUUID
PlatformInfo/Generic/ROM
```

直接启动会失败或功能异常（iCloud / App Store / FaceTime / iMessage 依赖它们）。

生成方法任选其一：

- **OCAT（OpenCore Auxiliary Tools）**：打开 `config.plist` → `PlatformInfo` → 点「生成」
- **macserial**（OpenCore 官方工具）：`./macserial -m MacBookPro16,2`
- **OpenCore Configurator**：`PlatformInfo` → `Generate`

`ROM` 填你自己网卡的 MAC，或随机生成。

### 2. KDK（关键，很多人会踩）

macOS 13 以后，所有第三方 kext 必须打包进 **AuxKC（Auxiliary Kernel Collection）** 并签名封存。
**重建 AuxKC 需要 KDK（Kernel Development Kit）**，缺失时会生成非法镜像，导致：

```
kernelmanagerd: No fileset UUID for auxKC
kernelmanagerd: Img4 error: format neither im4p nor img4
kernelmanagerd: invalid codeful kernel extension: ...
```

后果是**所有 codeful kext 失效，系统起不来**。

安装方法：

```bash
# 1. 查看你的 build
sw_vers -buildVersion

# 2. 从社区镜像下载对应 KDK（不需要开发者账号）
#    https://github.com/dortania/KdkSupportPkg/releases
#    本机对应：Kernel_Debug_Kit_26.7.2_build_25G332.dmg

# 3. 安装
hdiutil attach Kernel_Debug_Kit_26.7.2_build_25G332.dmg
sudo installer -pkg "/Volumes/Kernel Debug Kit/KernelDebugKit.pkg" -target /
hdiutil detach "/Volumes/Kernel Debug Kit"

# 4. 验证
ls /Library/Developer/KDKs/
```

验证 AuxKC 是否合法（输出必须带 UUID）：

```bash
kmutil inspect | grep 'auxiliary kext collection'
# 正常：auxiliary kext collection at /Library/KernelCollections/... (36939410-DD61-...)
# 异常：没有括号里的 UUID
```

### 3. 独显驱动不在 EFI 里

EFI 只负责引导，**NVIDIA 驱动装在系统目录**：

| 路径 | 内容 |
|---|---|
| `/Library/Extensions` | `NVRM.kext` / `NVRMFB.kext` / `NVRMAGDC.kext` / `NVAccel.kext` / `NMXAudio.kext` |
| `/Library/GPUBundles` | `NVMTLDriver.bundle`、`NVIDIAShared.bundle` |
| `/Library/NullMoth` | 安装器、备份、恢复脚本 |

安装方式：从 [nullmoth/nvidia-macos-driver](https://github.com/nullmoth/nvidia-macos-driver) 下载对应的 **1401 应用**，用它安装（会自动备份 config 并提供回滚）。

**换机器或重装系统后必须单独安装。**

### 4. BIOS 设置

| 项目 | 设置 |
|---|---|
| Secure Boot | **关闭** |
| CFG Lock | 关闭（或用 `AppleXcpmCfgLock`，本配置已启用） |
| VT-d | 关闭（或用 `DisableIoMapper`，本配置已启用） |
| 显存 DVMT | 建议 ≥ 60 MB；本机靠 `-igfxdvmt` + `framebuffer-stolenmem` 补丁 |
| 显卡模式 | **独显直连 / Discrete**（原因见[显卡说明](#显卡说明)） |

---

## 安装流程

> **注意**：本仓库的 `EFI/` **不能**用来做首次安装——它不含 NVIDIA 驱动，全新安装时没有画面输出。
> 必须先由 1401 制作带驱动的安装盘，装完系统后再换成这份 EFI。详细步骤见 [docs/install.md](docs/install.md)。

### 五个阶段

| 阶段 | 在哪做 | 做什么 |
|---|---|---|
| **① 制作安装盘** | Windows | 用 **1401 Windows 版**写入 U 盘（自动带上 NVIDIA 驱动注入） |
| **② 装系统** | 目标机 | 从 U 盘引导，安装 macOS（全程用 1401 生成的 EFI） |
| **③ 装驱动** | 已进入的 macOS | 运行 1401（macOS 版）把驱动装进 `/Library` |
| **④ 装 KDK** | 同上 | 安装对应 build 的 KDK，保证 AuxKC 能合法重建 |
| **⑤ 换 EFI** | 同上 | 生成三码 → 把本仓库 `EFI/` 复制进内置 ESP |

### 各阶段要点

**① 制作安装盘**

```text
1401 Windows 版 → 选择制作安装盘 → 下载 macOS 26.x → 写入 U 盘（≥ 32 GB）
```

生成的 EFI 已包含驱动注入（驱动来源：`/Library/NullMoth/kexts/<大版本>`）。

**② 装系统**

- BIOS：Secure Boot 关、CFG Lock 关、VT-d 关、**显卡模式=独显直连**
- OC 菜单先 **Reset NVRAM**，再选 Install macOS
- 会重启 2–3 次，每次都选磁盘上的 macOS 分区

**③ 装驱动**

安装完成后检查：

```bash
kmutil showloaded | grep nullmoth
# NVRM / NVRMFB / NVRMAGDC / NVAccel / NMXAudio
```

**④ 装 KDK**

```bash
sw_vers -buildVersion                      # 查 build，如 25G332
# 从 https://github.com/dortania/KdkSupportPkg/releases 下载同名 tag 的 dmg
hdiutil attach Kernel_Debug_Kit_26.7.2_build_25G332.dmg
sudo installer -pkg "/Volumes/Kernel Debug Kit/KernelDebugKit.pkg" -target /
kmutil inspect | grep 'auxiliary kext collection'   # 必须带 UUID
```

**⑤ 换 EFI**

```bash
# 生成三码（OCAT 或 macserial），填进 config.plist

# 挂载内置 ESP（diskutil 可能失败，用 mount_msdos）
sudo mkdir -p "/Volumes/NO NAME"
sudo /sbin/mount_msdos /dev/disk0s1 "/Volumes/NO NAME"

# 备份 1401 的 EFI 后替换
sudo cp -R "/Volumes/NO NAME/EFI" ~/Desktop/EFI-1401-backup
sudo rm -rf "/Volumes/NO NAME/EFI"
sudo ditto "$(pwd)/EFI" "/Volumes/NO NAME/EFI"
diskutil unmount "/Volumes/NO NAME"
```

### 装后检查清单

| 检查项 | 命令 | 期望 |
|---|---|---|
| 驱动版本 | `kmutil showloaded \| grep nullmoth` | 五个 nullmoth kext |
| AuxKC 合法性 | `kmutil inspect \| grep 'auxiliary kext collection'` | 带 UUID |
| Metal | `system_profiler SPDisplaysDataType` | Metal 3 |
| 内屏归属 | `ioreg -l -w0 \| grep 'IODisplayPrefsKey'` | `PEGP@0` |
| 刷新率 | 系统设置 → 显示器 | 180 Hz |
| USB 端口 | `ioreg -w0 -l \| grep -oE '\+-o (HS\|SS)[0-9]+'` | 10 个 |
| 音频 | `system_profiler SPAudioDataType` | 4 个输出 |

---

## 显卡说明

### 两种 BIOS 模式

| 模式 | 内屏由谁驱动 | 刷新率 | 核显可用 | 说明 |
|---|---|---|---|---|
| **独显直连（Discrete）** | RTX 5060 | **180 Hz** | ❌ 不能驱动内屏 | **推荐日常使用** |
| 混合（Hybrid） | UHD 770 | 60 Hz | ✅ | **必须接外屏**才能点亮内屏 |

### 混合模式的限制（已定位）

**现象**：BIOS 设为混合模式、**不接外接显示器**时，内屏只有背光没有画面。

**根因**：核显的 AUX 通道读不到内屏面板，日志中每 30 秒约 630 次：

```
[IGFB][ERROR][AUX] ddi = 0 Time out: 0x5d40023f
```

AUX 是显示链路的边带通道（读 EDID/DPCD、协商链路速率）。读不到 → 无法链路训练 → 面板不点亮。

**关键观察**：接上外屏后，核显能正常点亮内屏（AUX 超时降为 0 或仅初始化阶段出现）。推测与"存在第二个显示设备时系统采用不同的显示管道编程路径"有关。

**规避方案**：

- 日常：BIOS 用**独显直连**
- 需要核显：**接外屏**，或用 HDMI 假负载（dummy plug）
- 混合模式下内屏**只有 60 Hz**

### 核显驱动组成

| 组件 | 作用 |
|---|---|
| `WhateverXe.kext`（EFI 内） | Lilu 插件，负责核显的准入、路由、补丁 |
| `AppleIntelTGLGraphics.kext` | 核显图形栈（`/Library/Extensions`） |
| `AppleIntelTGLGraphicsFramebuffer.kext` | 帧缓冲 |
| `AppleIntelTGLCompat.kext` | 兼容层（`org.b00t0x.AppleIntelTGLCompat`） |
| `AppleIntelTGLGraphics{VADriver,MTLDriver,GLDriver}.bundle` | `/Library/GPUBundles` |

### 独显驱动组成

| 组件 | 作用 |
|---|---|
| `NVRM.kext` | 核心驱动 |
| `NVRMFB.kext` | 帧缓冲 |
| `NVRMAGDC.kext` | 显示控制 |
| `NVAccel.kext` | Metal 加速器 |
| `NMXAudio.kext` | HD Audio（macOS 26 不自带） |

---

## 已知问题

| 问题 | 状态 | 说明 |
|---|---|---|
| 混合模式无外屏时内屏不亮 | ⚠️ **已定位，未修复** | 核显 AUX 超时；需外屏或假负载 |
| 混合模式下**开机内屏只有背光** | ✅ **已定位，有解法** | 驱动开机跳过 eDP 链路训练。做一次 **≤2 秒**的休眠→唤醒即可点亮（见 [核显驱动方法](docs/核显驱动方法.md)） |
| 混合模式下**休眠超过 ~5 秒再唤醒会永久黑屏** | ⚠️ 已知限制 | 长 Doze 使面板深度断电，唤醒需重新训练链路但 AUX 不通 → 显示下线，只能重启 |
| 混合模式内屏只有 60 Hz | ⚠️ 无解 | 核显路径只提供 60 Hz 模式 |
| AirDrop / 接力 / 随航不可用 | ❌ 硬件限制 | Intel 网卡无 AWDL |
| 独显驱动需单独安装 | ℹ️ 设计如此 | 不在 EFI 内 |
| KDK 缺失会导致更新失败 | ⚠️ 必读 | 见[使用前必读](#2-kdk关键很多人会踩) |
| 蓝牙需 `-ibtcompatbeta` | ⚠️ 已知 | 13 代 CPU 兼容问题 |
| 第三方显示工具可能崩溃 | ⚠️ 已知 | BetterDisplay 初始化 NVIDIA Metal 时 SIGILL |
| 开机日志较吵 | ℹ️ 可关闭 | 去掉 `-v debug=0x100 keepsyms=1` |

## 不可用功能

| 功能 | 原因 |
|---|---|
| AirDrop 隔空投送 | `awdl0` 接口不存在，Intel 网卡 + AirportItlwm 不提供 AWDL |
| 接力 Handoff | 依赖 AWDL |
| 通用剪贴板 | 依赖 Handoff |
| 随航 Sidecar | 需要原生无线与 AWDL |
| 通用控制 Universal Control | 同上 |
| iPhone 镜像 | 同上 |
| AirPlay 接收 | 依赖 AWDL |

无线本身可用（802.11 a/b/g/n/ac，5 GHz 正常），**缺的只是 AWDL 这一层**。
需要 AirDrop/接力请更换博通网卡（如 BCM94360NG）。

---

## 目录结构

```
THIRD_PARTY_LICENSES.md   # 第三方组件版权与许可证清单
EFI/
├── BOOT/
│   └── BOOTx64.efi
└── OC/
    ├── ACPI/            # SSDT 补丁
    ├── Drivers/         # HfsPlus / OpenRuntime / ResetNvramEntry
    ├── Kexts/           # 27 个 kext
    ├── Resources/       # 主题与字体
    ├── Tools/           # NullMothSafe.efi
    └── config.plist
docs/
├── config-notes.md      # 配置逐项说明
├── install.md           # 从零安装流程
├── troubleshooting.md   # 问题速查（12 类）
├── 核显驱动方法.md       # 核显驱动完整流程（装驱动→激活→排错）
├── 疑难排查记录.md       # 详细排查过程与技术细节
└── 恢复步骤.txt          # 黑屏应急恢复
scripts/
├── 激活内屏.sh           # 触发 / 恢复内屏显示
└── igpu-diag.sh         # 核显状态采样
```

## 文档索引

| 文档 | 内容 | 适合谁 |
|---|---|---|
| [docs/install.md](docs/install.md) | 从零安装与装后检查 | 第一次装 |
| [docs/config-notes.md](docs/config-notes.md) | ACPI / DeviceProperties / Quirks 逐项说明 | 想改配置 |
| [docs/troubleshooting.md](docs/troubleshooting.md) | 12 类问题的现象与处理 | 遇到问题先看这个 |
| **[docs/核显驱动方法.md](docs/核显驱动方法.md)** | **装驱动 → 打补丁 → 建内核集合 → 激活内屏的完整流程 + 14 类问题排查** | **要用核显** |
| [docs/疑难排查记录.md](docs/疑难排查记录.md) | 完整的排查过程、技术细节、走过的弯路 | 想理解原理 |
| [docs/恢复步骤.txt](docs/恢复步骤.txt) | 黑屏 / 起不来时的应急流程 | 出事了 |
| **[THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md)** | 27 个 kext / EFI 驱动 / 主题的版权与许可证清单 | 关心合规 |

---

## 常见问题

**Q：开机卡在代码，最后一行是什么？**

- `ACPI Error` → ACPI 补丁与本机不匹配，先禁用 `ACPI/Add` 里的 SSDT 试
- `AppleIntelTGLGraphicsFramebuffer` 相关 → 核显驱动问题，可临时用 `-wex-noaccel`
- `Still waiting for root device` → USB 映射或 AHCI 问题

**Q：更新 macOS 或 kext 后开不了机？**

大概率是 AuxKC 非法。用 U 盘 EFI 引导 → 检查 KDK 是否安装 → 重建 AuxKC。详见 [疑难排查记录](docs/疑难排查记录.md#1-auxkc-与-kdk最大的坑)。

**Q：独显没画面 / 只显示核显？**

1. `kmutil showloaded | grep nullmoth` 看驱动是否加载
2. `ioreg -l -w0 | grep 'IODisplayPrefsKey'` 看内屏归谁（`PEGP@0` = 独显，`IGPU@2` = 核显）
3. 驱动没装 → 运行 1401 应用安装

**Q：为什么 `Processor Name` 显示不对？**

需要 `revpatch=cpuname` + `revcpu=1`（RestrictEvents 提供的品牌串补丁）。
注意 `ProcessorType` 填 `0` 会显示 "Unknown"，应保持 `3841`。

**Q：4K 视频卡顿？**

Safari 不加载 NVIDIA 的解码库（`libnvdec`），全程软解；**用 Chrome 即可走硬解**。
实测 4K HEVC 硬解 162 fps，软解只有 26 fps。

---

## 许可与致谢

### 许可

本仓库中由本人编写的部分（`config.plist`、ACPI 补丁、`docs/`、`scripts/`）以 **[MIT](LICENSE)** 发布。

`EFI/OC/Kexts/` 下的第三方组件版权归各自原作者，遵循其原始许可证
（BSD-3-Clause 15 个、GPL-3.0 5 个、GPL-2.0 5 个、MIT 2 个），
完整清单见 **[THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md)**。

> 本仓库**不包含**任何 Apple 原版二进制（不含 `apfs_aligned.efi`）。

### 致谢

- **OpenCore** 与 Acidanthera 全家桶：Lilu、VirtualSMC、AppleALC、NVMeFix、RestrictEvents、BrightnessKeys
- **[WhateverXe](https://github.com/b00t0x/WhateverXe)**（`org.b00t0x`）— Intel TGL 核显驱动
- **[nullmoth/nvidia-macos-driver](https://github.com/nullmoth/nvidia-macos-driver)** — NVIDIA Metal 驱动
- **OpenIntelWireless** — AirportItlwm
- **IntelBluetoothFirmware** / **BlueToolFixup**
- **VoodooI2C** / **VoodooPS2Controller** — 触控板
- **USBToolBox** — USB 端口映射
- **RTL812xLucy** — Realtek 2.5G
- **CpuTopologyRebuild**
- **AMFIPass**
- **dortania/KdkSupportPkg** — KDK 镜像

### 免责声明

本项目仅用于**学习与交流**。Hackintosh 违反 Apple 的 EULA，使用风险自负。
仓库中**不包含**任何 Apple 原版二进制文件，所有 kext 均来自各自的开源项目。

**请务必自行生成三码**，不要使用他人分享的序列号。

---

## English

OpenCore EFI for a MECHREVO JIGUANG laptop (Intel i7-13700HX, HM770) running macOS 26 Tahoe.

**You must generate your own SMBIOS values** (`SystemSerialNumber`, `MLB`, `SystemUUID`, `ROM`) — they are intentionally blank.

**You must install a matching KDK** before any kext update, otherwise the AuxKC rebuild produces an invalid collection and the system will not boot.

- iGPU: Intel UHD 770 via WhateverXe
- dGPU: RTX 5060 via [nullmoth/nvidia-macos-driver](https://github.com/nullmoth/nvidia-macos-driver) (Metal 3), installed in `/Library` — **not** part of this EFI
- **Hybrid mode cannot light the internal panel without an external display** (root cause: iGPU AUX timeout). Use discrete-only mode.
- **AirDrop / Handoff / Universal Control / Sidecar are unavailable** — no AWDL with Intel Wi-Fi.

See `docs/` for recovery steps and `scripts/` for diagnostic helpers.
