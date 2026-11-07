# 问题与解决方案

按「现象 → 原因 → 处理 → 状态」记录。**状态**一列很重要：

- ✅ **已验证**：本机复现并修复过
- ⚠️ **未证实**：观察到现象，但根因没有验证
- 💡 **推测**：基于原理的建议，本机未实测

> 需要完整的排查思路、技术细节和走过的弯路，见 [**疑难排查记录.md**](疑难排查记录.md)。

---

## 1. 混合显卡模式下，不接外屏内屏不亮

**现象**：BIOS 设为「混合 / Hybrid」时，开机后内屏黑屏或只有背光。接上外接显示器后，内屏恢复显示。

**原因**：✅ 已定位到失败环节。核显的 AUX 通道读不到内屏面板，日志中约 630 次：

```
[IGFB][ERROR][AUX] ddi = 0 Time out: 0x5d40023f
```

AUX 是 DP 的边带通道（读 EDID/DPCD、协商链路速率）。读不到 → 链路训练失败 → 面板不点亮。

接外屏时 AUX 超时降为 0 或仅初始化阶段短暂出现，内屏即可点亮。**根因（为什么单屏时 AUX 不通）尚未证实**，推测与"存在第二个显示设备时采用不同的显示管道编程路径"有关。

**处理**：
1. 日常用「独显直连 / Discrete」
2. 需要核显时接外屏，或用 HDMI 假负载（dummy plug）
3. 混合模式下内屏固定 **60 Hz**

**状态**：✅ 失败环节已定位；⚠️ 根因未证实；靠规避。

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

### 3.1 开机只有背光，没有画面

**现象**：混合模式 + 接外屏，开机后背光亮、系统在正常渲染（截屏有内容），但面板是黑的。

**原因**：✅ 已定位。核显驱动**假设固件已训练好 eDP 链路，于是跳过链路训练**：

```
[IGFB][INFO ][DISPLAY] FB0: Complete modeset       ← 报告"完成"
LINK_TRAINING 行数: 0                              ← 一次训练都没做
AUX 超时: 0 次                                     ← 一次 AUX 事务都没发
```

显示引擎被编程、背光点亮，但面板从未收到有效训练过的信号。

**解决**：做一次**极短的**休眠→唤醒，强制驱动重走完整初始化：

```bash
bash scripts/激活内屏.sh
```

或手动：

```bash
pmset displaysleepnow
```

**然后 2 秒内按一下空格键。**

### 3.2 为什么必须"短 Doze"

**Doze 时长是成败的唯一判据**（实测数据）：

| Doze 持续 | 结果 |
|---|---|
| **1.0 秒** | ✅ 成功 |
| **1.6 秒** | ✅ 成功 |
| 5.8 秒 | ❌ 失败 |
| 20 秒 | ❌ 失败 |
| 42 秒 | ❌ 失败 |
| 57 秒 | ❌ 失败 + `DBUF 2 power up timeout` |

短 Doze 面板电源不断，eDP 链路保持；长 Doze 面板深度断电，唤醒时必须重新训练链路，而训练需要 AUX —— **AUX 在这台机器上不通**。

> ⚠️ **`caffeinate -u` 不能唤醒屏幕**。它只阻止系统休眠。若用 `pmset displaysleepnow; sleep 3; caffeinate -u -t 2`，屏幕会一直黑到你手动碰它，间隔拉到几十秒，**必然失败**。

### 3.3 失败后的表现（只能重启）

```
[IGFB][ERROR][DISPLAY] DBUF 2 power up timeout            ← 长 Doze 特有
[IGFB][ERROR][AUX] ddi = 0 Time out: 0x8d40023f
[IGFB][ERROR][LINK_TRAINING] writeAUX failed: 0xe00002d6
[IGFB][ERROR][LINK_TRAINING] writeAUX failed: 0xe00002d8
[IGFB][ERROR][LINK_TRAINING] readAUX failed: 0xe00002d6
[IGFB][ERROR][LINK_TRAINING] Phase 1 of link training failed
                              - notifying AGDC to take display offline
[IGFB][ERROR][DISPLAY] FB0: Hardware mode set failed, err = 0xe00002bc
[IGFB][ERROR][DISPLAY] FB0 is not enabled                  ← 面板关闭，每秒刷错
```

**`FB0 is not enabled` 一旦出现，面板彻底关闭（连背光都没有），只能重启。**

**处理**：重启 → 改用短 Doze 重试。

### 3.4 必须避免的操作

| 操作 | 后果 |
|---|---|
| 合盖 | 长 Doze → 唤醒必失败 |
| 系统睡眠 | 同上 |
| 系统设置里手动「休眠显示器」 | 同上 |
| `sleep 3` 之后再唤醒 | 同上 |
| 用 `caffeinate -u` 当唤醒手段 | 屏幕不会醒，间隔被拉长 |

**状态**：✅ 已定位，✅ 有可用解法（短 Doze），⚠️ 无法做到自动/免手动。

> 完整说明见 [核显驱动方法.md](核显驱动方法.md)。

---

## 4. AirDrop / 接力 / 随航 全部不可用

**现象**：隔空投送找不到设备，接力、通用剪贴板、随航均无反应。

**原因**：✅ 已验证。`ifconfig awdl0` 报 `interface awdl0 does not exist`——AWDL 接口不存在。Intel 网卡 + AirportItlwm 不提供 AWDL 这一层。

**处理**：无软件方案。需要换博通网卡（BCM94360NG 等）。

**状态**：✅ 已确认不可用。

---

## 5. 蓝牙不工作

**现象**：蓝牙开关打不开，或能开但搜不到设备。

**原因**：13 代 CPU + Intel 蓝牙需要额外的兼容补丁。

**处理**：确认 boot-args 里带 `-ibtcompatbeta`，并且 `IntelBluetoothFirmware` + `IntelBTPatcher` + `BlueToolFixup` 三个 kext 都加载。

**状态**：✅ 本机正常工作（系统识别为 `THIRD_PARTY_DONGLE`，属正常）。

---

## 6. 外接屏不亮 / 独显没驱动

**现象**：插上外屏无信号，或系统信息里 RTX 5060 显示但无 Metal。

**原因**：NVIDIA 驱动不在 EFI 内，是独立装在 `/Library` 的。

**处理**：安装 [nullmoth/nvidia-macos-driver](https://github.com/nullmoth/nvidia-macos-driver)（本机 2.7.1），装完检查：

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

**处理**：按 [`恢复步骤.txt`](恢复步骤.txt) 走。核心是用 Windows 分区挂载 ESP 换回备份的 `config.plist`：

```
diskpart
list disk
select disk 0
list partition
select partition 1
assign letter=Z
exit
```

然后把备份的 `config.plist` 复制回 `Z:\EFI\OC\`。

**状态**：✅ 本机实际用过。

---

## 9. Windows 双系统引导入口消失

**现象**：OC 菜单里没有 Windows 了。

**原因**：开源版删掉了 `EFI/Microsoft/`（约 30 MB）。

**处理**：从你自己的 ESP 备份里把 `EFI/Microsoft` 复制回 `EFI/` 根目录，或直接从 BIOS 启动菜单选 Windows。

**状态**：✅ 本机未受影响（实际 ESP 未动）。

---

## 10. 升级 macOS 后失效

**现象**：系统更新后，核显驱动或 NVIDIA 驱动失效。

**原因**：kext 与系统版本强绑定，特别是 AuxKC 里的第三方驱动。

**处理**：
1. 升级前备份 ESP（`diskutil mount disk0s1` + `ditto`）
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

## 12. 音频无声 / 音频设备消失

**现象**：`system_profiler SPAudioDataType` 里没有任何输出设备，音量显示 `missing value`。

**原因**：✅ 已复现。macOS 26 不自带 HD Audio 驱动，需要第三方提供。常见冲突是两个音频驱动同时加载、抢同一个 HDA 控制器：

```
com.nullmoth.NMXAudio (1.0.0)         ← NVIDIA 驱动包 2.7+ 自带
org.voodoo.driver.VoodooHDA (3.0.2)   ← 旧方案
```

两者并存时**都不会生成输出设备**。

**处理**：只保留一个（推荐保留 NMXAudio）：

```bash
# 移走旧的
sudo mkdir -p /Library/Extensions-disabled
sudo mv /Library/Extensions/VoodooHDA.kext /Library/Extensions-disabled/

# 重建 AuxKC（必须有 KDK，见 README）
sudo kmutil rebuild

# 确认已移除
kmutil inspect | grep -ci voodoo    # 期望 0
```

**验证**：

```bash
system_profiler SPAudioDataType | grep 'Output Channels'
# 期望：板载模拟 + NVIDIA HDMI/DP，共 4 个输出
```

**状态**：✅ 已验证（NMXAudio 方案，4 个输出设备正常）。

---

## 13. 更新 NVIDIA 驱动（或任何 kext）后开不了机

**现象**：更新驱动后重启，卡在登录界面或 WindowServer 无响应（远程桌面能进）。日志出现：

```
kernelmanagerd: No fileset UUID for auxKC
kernelmanagerd: Img4 error: format neither im4p nor img4
kernelmanagerd: invalid codeful kernel extension: com.nullmoth.NVRMAGDC v2.7.1 ...
```

**原因**：✅ 已验证。macOS 13+ 要求所有第三方 kext 打包进 AuxKC 并签名封存，**重建 AuxKC 需要 KDK**。缺 KDK 时会生成没有 fileset UUID 的非法集合，导致所有 codeful kext 插入失败。

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

**预防**：更新任何 kext 前，先确认 `ls /Library/Developer/KDKs/` 非空。
