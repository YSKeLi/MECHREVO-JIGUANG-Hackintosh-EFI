# 关键配置说明

对本 EFI 的 `config.plist` 逐项说明，便于复现和排查。

---

## ACPI（10 个 SSDT）

| 文件 | 作用 |
|---|---|
| `SSDT-SBUS.aml` | 补 SMBus 设备，配合 AppleSMBus 与温度/风扇传感器 |
| `SSDT-EC.aml` | 伪造 Embedded Controller，避免 AppleACPIEC 抢真实 EC |
| `SSDT-GPI0.aml` | 为 I2C 触摸板提供 GPIO 中断映射 |
| `SSDT-MCHC.aml` | 内存控制器节点，供 AppleSMC 读取 |
| `SSDT-PLUG-ALT.aml` | CPU 电源管理（XCPM），13 代 CPU 必需 |
| `SSDT-RTCAWAC.aml` | 修正 RTC 唤醒，防止 CMOS 被清 |
| `SSDT-USB-Reset.aml` | 开机时复位 USB 控制器 |
| `SSDT-USBX.aml` | USB 供电属性（电流/电压上限） |
| `SSDT-XOSI.aml` | `_OSI` 重命名为 `XOSI`，让系统按 Windows 分支走 |
| `SSDT-PNLF.aml` | 背光设备 `PNLF`，配合 BrightnessKeys 调节亮度 |

## DeviceProperties

| 设备路径 | 键 | 值 | 说明 |
|---|---|---|---|
| `PciRoot(0x0)/Pci(0x2,0x0)` | `framebuffer-patch-enable` | `01000000` | 启用帧缓冲补丁（核显） |
| | `framebuffer-stolenmem` | `0000c003` → **60 MB** | 显存 stolen memory 补丁 |
| `PciRoot(0x0)/Pci(0x1,0x1)/Pci(0x0,0x0)` | `acpi-wake-type` | `1` | NVIDIA 显卡的 ACPI 唤醒类型 |

> 注意：本机 DVMT 预分配较小，靠 `-igfxdvmt` + `framebuffer-stolenmem=60MB` 撑起核显显存。

## Booter / Quirks

| 项 | 值 | 说明 |
|---|---|---|
| `AllowRelocationBlock` | ✅ | 允许内核重定位块 |
| `AvoidRuntimeDefrag` | ✅ | 绕过运行时内存碎片整理（必需） |
| `EnableSafeModeSlide` | ✅ | 安全模式也启用 slide |
| `ProtectUefiServices` | ✅ | 保护 UEFI 服务，防固件覆盖 |
| `ProvideCustomSlide` | ✅ | 提供自定义 slide 值 |
| `RebuildAppleMemoryMap` | ✅ | 重建内存映射 |
| `SetupVirtualMap` | ✅ | 设置虚拟内存映射 |
| `SyncRuntimePermissions` | ✅ | 同步运行时权限 |

## Kernel / Quirks

| 项 | 值 | 说明 |
|---|---|---|
| `AppleXcpmCfgLock` | ✅ | 绕过 CFG Lock 未解锁的问题 |
| `CustomSMBIOSGuid` | ✅ | 使用自定义 SMBIOS GUID |
| `DisableIoMapper` | ✅ | 关闭 VT-d 映射（BIOS 未关 VT-d 时必需） |
| `DisableLinkeditJettison` | ✅ | 关闭 linkedit 丢弃，兼容 Lilu |
| `PanicNoKextDump` | ✅ | panic 时不 dump kext 列表，日志更干净 |
| `PowerTimeoutKernelPanic` | ✅ | 避免电源超时导致 panic |
| `ProvideCurrentCpuInfo` | ✅ | 提供当前 CPU 信息（13 代必需） |
| `SetApfsTrimTimeout` | `-1` | 关闭 APFS TRIM 超时 |

## UEFI

**Drivers**

| 文件 | 作用 |
|---|---|
| `OpenRuntime.efi` | OpenCore 运行时服务（必需） |
| `HfsPlus.efi` | 读取 HFS+ 分区 |
| ~~`apfs_aligned.efi`~~ | **本仓库不包含**（Apple 派生二进制，许可风险）。`config.plist` 中保留条目但 `Enabled=False`；需要时自行从 [OCLP](https://github.com/dortania/OpenCore-Legacy-Patcher) 获取 |
| `ResetNvramEntry.efi` | 启动菜单里的「Reset NVRAM」入口 |

**Quirks**

| 项 | 值 | 说明 |
|---|---|---|
| `ReleaseUsbOwnership` | ✅ | 释放 USB 控制器所有权 |
| `RequestBootVarRouting` | ✅ | 接管启动变量路由，双系统必需 |
| `ResizeGpuBars` | `-1` | 关闭 Resizable BAR 调整 |

## NVRAM

| 键 | 值 | 说明 |
|---|---|---|
| `csr-active-config` | `0x0A43` | **SIP 部分禁用**，用于加载第三方 kext（NVIDIA、WhateverXe） |
| `boot-args` | 见 README | 内核启动参数 |
| `revcpu` | `1` | RestrictEvents：伪装 CPU 名称 |
| `revcpuname` | `13th Gen Intel(R) Core(TM) i7-13700HX` | RestrictEvents：CPU 显示名 |
| `revpatch` | `sbvmm,cpuname` | RestrictEvents：机型补丁 + CPU 名 |
| `run-efi-updater` | `No` | 阻止固件自动更新 |
| `SystemAudioVolume` | `46` | 开机音量 |

> `csr-active-config = 0x0A43` 意味着 SIP 未完全关闭，但允许未签名 kext、允许文件系统访问等。装 NVIDIA 驱动和 WhateverXe 都需要它。

## Misc

**Security**

| 项 | 值 |
|---|---|
| `SecureBootModel` | `Disabled` |
| `Vault` | `Optional` |
| `ScanPolicy` | `0`（扫描所有分区） |
| `BlacklistAppleUpdate` | `true` |
| `ExposeSensitiveData` | `7` |
| `AllowSetDefault` | `true` |

**Boot**

| 项 | 值 |
|---|---|
| `ShowPicker` | `true` |
| `Timeout` | `5` 秒 |
| `PickerMode` | `Builtin` |
| `LauncherOption` | `Disabled` |
| `HibernateMode` | `None` |

## 其他

- **USB 映射**：`USBToolBox.kext` + `UTBMap.kext`，本机用 USBToolBox 生成
- **音频**：`AppleALC` + `SimpleHDA`（自定义声卡驱动），SSDT 中带 HDEF
- **无线**：`AirportItlwm`（不是 `itlwm`，`itlwm` 需要 HeliPort，本机未用）
- **蓝牙**：`IntelBluetoothFirmware` + `IntelBTPatcher` + `BlueToolFixup`，需 `-ibtcompatbeta`
