# 问题与解决方案

> 2026-11-16 更新。当前版本见 [当前状态](当前状态.md)。混合模式内屏仍未修复；旧激活操作已发生回归。本页第 1、3 节已按 11 月 11 日原始记录修正，详见 [内屏排查更新](内屏排查更新-20261116.md)。本轮未重新测试。

按「现象 → 原因 → 处理 → 状态」记录。**状态**一列很重要：

- ✅ **已验证**：本机复现并修复过
- ⚠️ **未证实**：观察到现象，但根因没有验证
- 💡 **推测**：基于原理的建议，本机未实测

> 需要完整的排查思路、技术细节和走过的弯路，见 [**疑难排查记录.md**](疑难排查记录.md)。

---

## 1. 混合显卡模式下内屏不亮

**当前状态**：仍未修复。用户曾能在接外屏后通过熄屏／唤醒点亮内屏，后来相同操作也失效，需追踪版本回归。

**历史观察**：部分旧启动有大量 AUX 超时；当时也记录过接外屏后显示恢复。这些现象只适用于各自启动现场，不能据此认定“接外屏或假负载即可修复”。

11 月 11 日复核的另一份混合模式黑屏采集已经读出完整 EDID 和 DPCD，链路一度训练成功，约四秒后均衡与符号锁定状态丢失；该次文本日志没有 AUX、DBUF 或 Phase 1 错误。当前重点是接管后的链路保持与版本差异，不能把旧 AUX 错误直接套作唯一原因。

当前可用基线为独显输出内屏 2560×1600、180 Hz。后续试验需保留可启动配置和配套驱动备份，详见 [内屏排查更新](内屏排查更新-20261116.md)。

---

## 2. 核显 Metal 崩溃

**现象**：某些图形负载下花屏、卡死、或应用闪退。

**原因**：早期版本的 WhateverXe + 旧 Graphics payload 组合不稳定。升级到 **WhateverXe 0.7.0 + Graphics 0.4.0 payload** 后，本机实测 WindowServer **0 崩溃**，Metal 2 设备正常。

**处理**：
1. 先按 [`恢复步骤.txt`](恢复步骤.txt) 判断是 EFI 问题还是驱动问题
2. 若崩溃后能进系统，重启即可恢复
3. 确认 Graphics payload 是否为 0.4.0（`AppleIntelTGLGraphicsMTLDriver.bundle` 的版本）
4. 仍频繁崩溃时，可临时在 boot-args 加 `-wex-noaccel` 关闭加速器

**状态**：✅ 本机升级后未再复现；上游仍在迭代。

---

## 3. 混合模式下内屏只有背光（开机不亮 / 休眠后黑屏）

### 3.1 已确认的故障现场

核显加速、内屏识别和输出模式已建立，系统认为内屏在线，但物理面板只有背光。11 月 11 日复核的原始 DPCD 记录显示：链路曾在 HBR2 两通道下训练完成，约四秒后只剩时钟恢复完成位，均衡和符号锁定位不再完整。

原文依据“LINK_TRAINING 错误行数为零”推断“驱动跳过了训练”，这个判断不成立。没有错误日志不代表未执行 AUX 或训练；`Complete modeset` 也不能证明物理出画面。

固件快照为 8 bpc／4 通道，驱动随后请求 10 bpc／2 通道；10 bpc 值来自寄存器写请求，不等于硬件读回。色深值得单变量验证，但尚未证明是唯一原因。

### 3.2 短 Doze 的历史观察

11 月 6–7 日旧记录曾将 1.0 秒和 1.6 秒的 Doze 标为成功，将较长 Doze 标为失败。后续用户确认相同熄屏／唤醒操作已不再点亮内屏，因此这些样本不足以证明一个通用的 2～5 秒阈值，更不能将 Doze 时长称为唯一判据。

旧操作 `pmset displaysleepnow` 后快速按键，以及 `scripts/激活内屏.sh`，仅保留为历史试验记录，不是当前恢复承诺。脚本返回值、系统显示在线和无错误日志均不能代替物理画面验收；显示电源切换也可能令当前画面中断。

### 3.3 旧失败日志如何使用

旧启动曾出现 `AUX Time out`、`Phase 1 of link training failed`、`DBUF 2 power up timeout` 和 `FB0 is not enabled`。应核对它们属于哪次启动、当时的驱动组合和实际显卡路径，再判断失败阶段。

这些记录不足以证明所有故障都由长 Doze 导致，也不足以断言软件绝无恢复可能。恢复时选择已经验证的启动配置，并按 [恢复步骤](恢复步骤.txt) 区分 EFI 与系统驱动回退。

**状态**：混合模式内屏仍未修复，最后一次确实点亮的完整版本基线尚未找到。后续一次验证一个变量，同时记录实际画面、输出配置与 DPCD 状态；详见 [内屏排查更新](内屏排查更新-20261116.md)。

---

## 4. 隔空投送可发现但等待或失败

当前采用 ForbiddenItlwm 0.5.4-beta.2 + BTLEAdvFixup 0.9.1。已见双向成功，但两次发送在 Bonjour 设备发现阶段约 45 秒后失败，另一次上传流读取错误。

先确认新版实际加载、awdl0 已启用，再按具体事务核对 ASK、UPLOAD 应答和导入完成；只看到图标或 StateMachine END 不足以认定成功。详见 [隔空投送](隔空投送.md)。

历史 AirportItlwm 配置没有 AWDL 的结论不再适用于当前配置；接力、随航等本轮未测。

---

## 5. 蓝牙不工作

本机当前组合为 IntelBluetoothFirmware 2.5.0 + BlueToolFixup 2.7.3 + BTLEAdvFixup 0.9.1，保留 -ibtcompatbeta 与 -btleadv；IntelBTPatcher 禁用。不要按旧版说明把 IntelBTPatcher 与当前补丁一起重新启用。

先检查已加载版本、蓝牙开关及对应系统构建，再判断硬件或补丁。系统识别 THIRD_PARTY_DONGLE 是本机观察值，单靠这个名称不能判断所有功能正常。

---

## 6. 外接屏不亮 / 独显没驱动

**现象**：插上外屏无信号，或系统信息里 RTX 5060 显示但无 Metal。

**原因**：NVIDIA 驱动不在 EFI 内，是独立装在 `/Library` 的。

**处理**：安装 [nullmoth/nvidia-macos-driver](https://github.com/nullmoth/nvidia-macos-driver)（本机当前实际加载 2.6.6），装完检查：

```bash
kextstat | grep nullmoth        # 应有 NVRM / NVRMFB / NVRMAGDC / NVAccel
system_profiler SPDisplaysDataType | grep "Metal Support"   # 应为 Metal 3
```

**状态**：✅ 本机正常。

---

## 7. 引导卡在代码 / 卡在 Apple 标志

**现象**：OC 菜单能进，但启动中途卡住。

**排查顺序**：
1. 去掉 `-v` 关掉啰嗦模式，看是否只是速度慢
2. 回忆最近改过什么（config、kext、SSDT），先回滚
3. 用 U 盘启动另一套 EFI 验证是 EFI 还是系统问题
4. 检查 BIOS 有没有被重置（更新、断电后）

**状态**：💡 通用流程。

---

## 8. EFI 坏了，进不去 macOS

**现象**：开机直接黑屏、卡住，或 OC 菜单都没了。

**处理**：按 [恢复步骤](恢复步骤.txt) 区分 EFI 与系统驱动问题。先根据实际磁盘、分区类型和内容确认目标 ESP，再挂载；不要照抄其他机器的磁盘或分区编号。

保留当前文件作为故障证据，从自己已经启动验证过的配套备份恢复。若改过 config 与驱动，需一起核对恢复；OpenCore.efi 与 BOOTx64.efi 也应配套。保留目标盘的 EFI/Microsoft 和其他引导目录，公开版空身份配置不能直接当本机原配置恢复。

**状态**：历史上用过 EFI 回退；具体目标和恢复文件需按本次故障核实。

---

## 9. Windows 双系统入口消失

公开目录不含 EFI/Microsoft，部署时必须保留原盘该目录；不要删除整个 EFI 根目录来替换公开包。

若误删，先从自己的完整 EFI 备份恢复 Microsoft 目录。必要时再用 Windows 恢复介质修引导。单有公开版 BOOT / OC 不能代替 Windows 自己的引导文件。

---

## 10. 升级 macOS 后失效

**现象**：系统更新后，核显驱动或 NVIDIA 驱动失效。

**原因**：kext 与系统版本强绑定，特别是 AuxKC 里的第三方驱动。

**处理**：
1. 升级前先用 `diskutil list` 核对实际目标磁盘和 ESP，再挂载并完整备份；磁盘编号不能照抄历史示例。
2. 升级后如失效，重装对应版本的 WhateverXe / nvidia-macos-driver
3. 保留一份能启动的旧 EFI

**状态**：💡 建议流程。

---

## 11. 三码问题导致 iCloud / App Store 异常

**现象**：登录 iCloud 提示验证失败，或 App Store 无法下载。

**原因**：三码（序列号/MLB/UUID/ROM）与其他设备冲突，或被苹果标记。

**处理**：用 OCAT 重新生成一套三码，清 NVRAM 后重启。

**状态**：✅ 通用处理方式。

---

## 12. 音频无声或设备消失

本机当前加载 VoodooHDA 3.0.2，已枚举扬声器、耳机和模拟麦克风；NMXAudio 未加载。历史曾遇到 NMXAudio 与 VoodooHDA 冲突，相关过程保存在疑难排查记录中。

先核对实际加载的驱动与设备枚举，不要照旧说明把当前 VoodooHDA 直接移除。若决定更换 /Library 中的音频方案，先保存驱动和 AuxKC 的配套备份，按安装器要求处理内核集合，再重启验证实际声音与麦克风。

---

## 13. 更新系统中的图形 / 音频驱动后开不了机

**现象**：更新驱动后重启，卡在登录界面或 WindowServer 无响应（远程桌面能进）。日志出现：

```
kernelmanagerd: No fileset UUID for auxKC
kernelmanagerd: Img4 error: format neither im4p nor img4
kernelmanagerd: invalid codeful kernel extension: com.nullmoth.NVRMAGDC v2.7.1 ...
```

**原因**：✅ 已验证。本节历史故障涉及安装进 `/Library` 的系统扩展及其 AuxKC；当时重建所需的 KDK 或参数未配套，出现集合内容不一致。EFI 注入的驱动属于另一种加载路径。

**排查**：

```bash
kmutil inspect | grep 'auxiliary kext collection'
# 异常：没有括号里的 UUID
# 正常：(36939410-DD61-62AF-89F5-008F7F1A81BF)
```

**处理**：

1. 用 U 盘 EFI 或备份的 config 进入系统
2. 安装对应 build 的 KDK：

```bash
sw_vers -buildVersion      # 例：25G332
# 从 https://github.com/dortania/KdkSupportPkg/releases 下载对应 dmg
hdiutil attach Kernel_Debug_Kit_26.7.2_build_25G332.dmg
sudo installer -pkg "/Volumes/Kernel Debug Kit/KernelDebugKit.pkg" -target /
hdiutil detach "/Volumes/Kernel Debug Kit"
```

3. 重建 AuxKC：

```bash
sudo kmutil rebuild
kmutil inspect | grep 'auxiliary kext collection'   # 确认有 UUID
```

4. 必要时回滚驱动：`/Library/NullMoth/` 下有安装器自动创建的备份

**状态**：✅ 已验证（装 KDK 后同一次更新一次成功）。

**范围修正（2026-11-16）**：上文是当时 /Library 驱动与 AuxKC 的排查记录。EFI 注入驱动的更新不需要照此重建 AuxKC；不要只凭一条错误或一个 UUID 判断全部驱动是否可用。改系统驱动时应核对匹配的 KDK、集合内容与实际启动日志。
