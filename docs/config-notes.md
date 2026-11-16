# 当前配置说明（2026-11-16）

数据来自本机当前 config.plist；公开版清空身份字段，并按用户要求移除 MechrevoControl 驱动及配置项；release 另禁用未打包的 apfs_aligned.efi。其余配置从本机快照同步。

## ACPI

| 补丁 | 状态 |
| --- | --- |
| SSDT-SBUS.aml | 启用 |
| SSDT-EC.aml | 启用 |
| SSDT-GPI0.aml | 启用 |
| SSDT-MCHC.aml | 启用 |
| SSDT-PLUG-ALT.aml | 启用 |
| SSDT-RTCAWAC.aml | 启用 |
| SSDT-USB-Reset.aml | 启用 |
| SSDT-USBX.aml | 启用 |
| SSDT-XOSI.aml | 启用 |
| SSDT-PNLF.aml | 启用 |

## EFI 注入驱动

| BundlePath | 状态 | MinKernel | MaxKernel |
| --- | --- | --- | --- |
| `Lilu.kext` | 启用 | 不限 | 不限 |
| `WhateverXe.kext` | 启用 | 不限 | 不限 |
| `AMFIPass.kext` | 启用 | 20.0.0 | 不限 |
| `IntelBluetoothFirmware.kext` | 启用 | 不限 | 不限 |
| `BlueToolFixup.kext` | 启用 | 21.0.0 | 不限 |
| `BTLEAdvFixup.kext` | 启用 | 25.0.0 | 25.99.99 |
| `BrightnessKeys.kext` | 启用 | 不限 | 不限 |
| `CpuTopologyRebuild.kext` | 启用 | 不限 | 不限 |
| `IntelBTPatcher.kext` | 禁用 | 不限 | 不限 |
| `NVMeFix.kext` | 启用 | 18.0.0 | 不限 |
| `RTL812xLucy.kext` | 启用 | 不限 | 不限 |
| `RestrictEvents.kext` | 启用 | 不限 | 不限 |
| `VirtualSMC.kext` | 启用 | 不限 | 不限 |
| `SMCBatteryManager.kext` | 启用 | 不限 | 不限 |
| `SMCLightSensor.kext` | 启用 | 不限 | 不限 |
| `SMCProcessor.kext` | 启用 | 不限 | 不限 |
| `SMCSuperIO.kext` | 启用 | 不限 | 不限 |
| `USBToolBox.kext` | 启用 | 不限 | 不限 |
| `UTBMap.kext` | 启用 | 不限 | 不限 |
| `VoodooI2C.kext/Contents/PlugIns/VoodooI2CServices.kext` | 启用 | 不限 | 不限 |
| `VoodooI2C.kext/Contents/PlugIns/VoodooGPIO.kext` | 启用 | 不限 | 不限 |
| `VoodooI2C.kext` | 启用 | 不限 | 不限 |
| `VoodooI2C.kext/Contents/PlugIns/VoodooInput.kext` | 启用 | 不限 | 不限 |
| `VoodooI2CHID.kext` | 启用 | 不限 | 不限 |
| `VoodooPS2Controller.kext` | 启用 | 不限 | 不限 |
| `VoodooPS2Controller.kext/Contents/PlugIns/VoodooInput.kext` | 禁用 | 不限 | 不限 |
| `VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Keyboard.kext` | 启用 | 不限 | 不限 |
| `VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Mouse.kext` | 启用 | 不限 | 不限 |
| `VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Trackpad.kext` | 启用 | 不限 | 不限 |
| `WhateverGreen.kext` | 禁用 | 不限 | 不限 |
| `XHCI-unsupported.kext` | 启用 | 不限 | 不限 |
| `AirportItlwm.kext` | 禁用 | 25.0.0 | 25.99.99 |
| `ForbiddenItlwm.kext` | 启用 | 25.0.0 | 25.99.99 |

Lilu 在相关插件之前；USBToolBox 在 UTBMap 之前；VoodooI2C 所需服务按当前顺序保留。AirportItlwm 与 IntelBTPatcher 文件存在但没有启用，避免与当前 AirDrop 方案同时生效。

## UEFI 驱动

| 文件 | 状态 |
| --- | --- |
| apfs_aligned.efi | 文件不含，配置禁用 |
| HfsPlus.efi | 启用 |
| OpenRuntime.efi | 启用 |
| ResetNvramEntry.efi | 启用 |

BOOTx64.efi 与 OpenCore.efi 来自同一次本机快照。公开目录不包含 Microsoft 引导目录，部署时需保留目标磁盘原有目录。

## 参数与硬件设置

完整 boot-args 见 [README](../README.md)。当前移除了历史的 `-disablegfxfirmware`，保留本机原有图形、蓝牙和调试参数，并包含 AirDrop 的实验参数。

DeviceProperties、USB 映射、ACPI 与 Booter / Kernel / UEFI Quirks 均按实际配置同步。图形静态补丁位于系统驱动文件中，不能仅凭 EFI 中的参数推断它们已安装。

`SecureBootModel` 仍为 Disabled，三码仍采用 MacBookPro16,2 机型配置但清空唯一身份值。安全设置是这台实验机器的状态记录，不是通用配置建议。

## 系统中另装的组件

NVIDIA 四个组件当前 2.6.6、VoodooHDA 3.0.2；WhateverXe 的图形系统组件与 GPUBundles 另装在 /Library。本次同步没有安装或重建它们。改动这部分前需保存驱动与 AuxKC 的配套备份。

MechrevoControl 已按用户要求从桌面 EFI 副本中移除；本机运行 EFI 未作更改。
