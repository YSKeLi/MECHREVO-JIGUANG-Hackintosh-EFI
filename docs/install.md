# 安装步骤

> 本机是从零安装的。核心流程是：**Windows 上用 1401 做安装盘 → 装系统 → 装驱动和 KDK → 换成仓库这份 EFI**。
> **动手前先把 BIOS 设置做完**（见下方第 2 节）。

---

## 0. 为什么不能直接用仓库的 EFI 装系统

仓库的 `EFI/` **不包含 NVIDIA 驱动**——驱动只装在系统目录 `/Library`（见 [README](../README.md#3-独显驱动不在-efi-里)）。

本机 BIOS 用独显直连时，**只有 NVIDIA 显卡能输出画面**。全新安装时 `/Library` 里还没有驱动，因此：

- 安装器画面出不来
- 就算能启动，也看不到任何界面

所以必须先用 **1401 的 Windows 客户端**制作一份「带驱动」的安装盘，装完系统、把驱动装进 `/Library` 之后，再换成仓库这份定制 EFI。

> 参考：`/Library/NullMoth/kexts/15` 和 `/Library/NullMoth/kexts/26` 是按 macOS 大版本存放的驱动，安装器会在制作安装盘时把对应版本注入进去。

---

## 1. 在 Windows 上制作安装盘（1401）

**操作环境：Windows**

1. 下载 [nullmoth/nvidia-macos-driver](https://github.com/nullmoth/nvidia-macos-driver) 的 **1401 Windows 版**
2. 插上 U 盘（≥ 32 GB，会被格式化）
3. 在 1401 里选择制作安装盘，按提示：
   - 下载 macOS 安装包（26.x）
   - 生成配套的 OpenCore EFI（**其中已包含 NVIDIA 驱动的注入**）
   - 写入 U 盘
4. 完成后 U 盘上有：macOS 安装器 + `EFI/`（1401 生成的版本）

> 这一步也可以在已有的 macOS 系统上做（1401 有 macOS 版），但**首次安装必须用 Windows 版**——
> 因为 macOS 版要求系统里已经能跑起来。

---

## 2. BIOS 设置（必须）

| 项 | 设置 |
|---|---|
| CFG Lock | 关闭（或用 `AppleCpuPmCfgLock`） |
| Secure Boot | 关闭 |
| VT-d | 关闭（或用 `DisableIoMapper`） |
| **显卡模式** | **独显直连 / Discrete** |
| DVMT | ≥ 60 MB（本机靠 `-igfxdvmt` + `framebuffer-stolenmem` 补丁） |
| Fast Boot | 关闭 |
| CSM | 关闭 |

---

## 3. 安装 macOS

1. 开机按 **F12 / F11** 选 U 盘
2. 进 OC 菜单，先进 **Reset NVRAM**（清掉旧变量）
3. 重启，选 **Install macOS**
4. 按提示分区、安装（会重启 2–3 次，每次都选 Install / macOS 分区）

> 全程用 1401 生成的 EFI，**不要中途换成仓库的 EFI**——那时驱动还没进系统，换了就没画面。

---

## 4. 首次进系统后

用 1401 的 EFI 引导进入桌面，然后：

### 4.1 装 NVIDIA 驱动到 `/Library`

运行 **1401（macOS 版）** → 安装驱动。它会：

- 把 kext 装到 `/Library/Extensions`（`NVRM` / `NVRMFB` / `NVRMAGDC` / `NVAccel` / `NMXAudio`）
- 把 bundle 装到 `/Library/GPUBundles`
- 自动备份 `config.plist` 并提供回滚

检查：

```bash
kmutil showloaded | grep nullmoth
# 期望：NVRM / NVRMFB / NVRMAGDC / NVAccel / NMXAudio

system_profiler SPDisplaysDataType | grep "Metal Support"
# 期望：Metal 3
```

### 4.2 安装 KDK（关键）

**不做这一步，后面任何 kext 更新都可能让系统起不来。**

macOS 13+ 要求第三方 kext 打包进 AuxKC 并签名封存，而重建 AuxKC 需要 **KDK**。

```bash
# 1. 查 build
sw_vers -buildVersion
# 例：25G332

# 2. 从社区镜像下载对应 KDK（不需要开发者账号）
#    https://github.com/dortania/KdkSupportPkg/releases
#    找 tag 与你的 build 完全一致的那个

# 3. 安装
hdiutil attach Kernel_Debug_Kit_26.7.2_build_25G332.dmg
sudo installer -pkg "/Volumes/Kernel Debug Kit/KernelDebugKit.pkg" -target /
hdiutil detach "/Volumes/Kernel Debug Kit"

# 4. 验证
ls /Library/Developer/KDKs/
# → KDK_26.7.2_25G332.kdk

# 5. 验证 AuxKC 合法（必须带 UUID）
kmutil inspect | grep 'auxiliary kext collection'
```

正常输出：

```
auxiliary kext collection at /Library/KernelCollections/AuxiliaryKernelExtensions.kc (36939410-DD61-62AF-89F5-008F7F1A81BF)
```

括号里**没有 UUID** 说明 KDK 没装好或重建失败，详见 [疑难排查记录](疑难排查记录.md#1-auxkc-与-kdk最大的坑)。

---

## 5. 换成仓库的 EFI

系统能正常启动后，把仓库的定制 EFI 替换进内置 ESP。

### 5.1 先生成三码

仓库的 `config.plist` 中以下字段**已清空**，必须自己填：

```
PlatformInfo/Generic/SystemSerialNumber
PlatformInfo/Generic/MLB
PlatformInfo/Generic/SystemUUID
PlatformInfo/Generic/ROM
```

用 **OCAT**（`PlatformInfo` → 生成）或 `macserial -m MacBookPro16,2`。
`ROM` 填网卡 MAC 或随机生成。

### 5.2 复制进 ESP

```bash
# 挂载内置 ESP（diskutil 可能挂不上，用 mount_msdos）
sudo mkdir -p "/Volumes/NO NAME"
sudo /sbin/mount_msdos /dev/disk0s1 "/Volumes/NO NAME"

# 先备份 1401 生成的那份
sudo cp -R "/Volumes/NO NAME/EFI" ~/Desktop/EFI-1401-backup

# 替换
sudo rm -rf "/Volumes/NO NAME/EFI"
sudo ditto "$(pwd)/EFI" "/Volumes/NO NAME/EFI"

# 卸载
diskutil unmount "/Volumes/NO NAME"
```

### 5.3 拔盘重启

确认能从内置磁盘引导，并且：

- 内屏正常（独显直连，180 Hz）
- 独显 Metal 3 正常
- USB 端口是 `HS01`~`HS06` / `SS01`~`SS04`

---

## 6. 安装后检查清单

逐项确认，**任何一项不对都先别继续**：

```bash
# 1. 驱动版本
kmutil showloaded | grep nullmoth

# 2. AuxKC 合法性（必须有 UUID）
kmutil inspect | grep 'auxiliary kext collection'

# 3. 显卡
system_profiler SPDisplaysDataType | head -20

# 4. 内屏归属（PEGP@0 = 独显，IGPU@2 = 核显）
ioreg -l -w0 | grep 'IODisplayPrefsKey" ='

# 5. USB 端口
ioreg -w0 -l | grep -oE '\+-o (HS|SS)[0-9]+'

# 6. 音频
system_profiler SPAudioDataType | grep 'Output Channels'

# 7. 无线
ifconfig en0 | head -3

# 8. 蓝牙
system_profiler SPBluetoothDataType | grep -E "State|Chipset"
```

| 检查项 | 期望 |
|---|---|
| 驱动版本 | NVRM / NVAccel / NVRMFB / NVRMAGDC / NMXAudio |
| AuxKC | 带 UUID |
| Metal | Metal 3 |
| 内屏 | `PEGP@0`，2560×1600 @180 Hz |
| USB | 10 个端口（HS01-06 + SS01-04） |
| 音频 | 4 个输出（板载模拟 + HDMI/DP） |

---

## 7. 常见卡点

| 卡在哪 | 先试 |
|---|---|
| 卡 `EXITBS:START` | 检查 `SetupVirtualMap` / `RebuildAppleMemoryMap` |
| 卡在 Apple 标志 | 加 `-v` 看日志，回滚最近改动 |
| 安装器没画面 | BIOS 确认是独显直连；确认用的是 1401 生成的 EFI（带驱动） |
| 装完进不去桌面 | 检查 KDK 与 AuxKC UUID（[troubleshooting #13](troubleshooting.md#13-更新-nvidia-驱动或任何-kext后开不了机)） |
| 内屏黑但外屏亮 | 见 README「显卡说明」——混合模式的限制 |
| 无限重启 | 清 NVRAM；检查三码是否为空 |
| 没有任何音频设备 | VoodooHDA 与 NMXAudio 冲突（[troubleshooting #12](troubleshooting.md#12-音频无声--音频设备消失)） |
