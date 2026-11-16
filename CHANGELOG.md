# v1.1（2026-11-16）

本版同步 Intel 隔空投送驱动与实测记录，并修正混合模式内屏和恢复文档。适用基线为机械革命极光 X（i7-13700HX、RTX 5060 Laptop、AX201），macOS 26.7.2（25G332）。

## 本版变化

- 加入 ForbiddenItlwm 0.5.4-beta.2（Tahoe）和 BTLEAdvFixup 0.9.1，更新启动参数与依赖顺序；AirportItlwm、IntelBTPatcher 保留但禁用。
- 隔空投送已观察到双向各一次完整成功，同时保留设备发现超时和上传中断的失败记录；尚不能视为完全稳定。
- 更新内屏排查：混合模式曾可通过熄屏／唤醒激活，后来发生回归。原始记录显示链路初次训练成功后失锁，混合模式内屏仍未修复；当前确认可用的是 NVIDIA 输出内屏 2560×1600、180 Hz。
- 修正历史图形文档的确定性归因、stolenmem 配置示例和恢复路径；激活脚本不再根据文本日志无错误判断面板已点亮。
- 清理未使用的 AppleALC／AppleALCU，移除 MechrevoControl；补充新增组件许可证、文件校验清单和安装范围说明。

## 使用范围

发布包只包含本仓库的公开 EFI、说明、脚本和许可证。唯一身份字段已清空，使用者需填写自己的 SystemSerialNumber、MLB、SystemUUID、ROM。部署时保留目标盘已有的 EFI/Microsoft。

NVIDIA、核显系统图形栈和 VoodooHDA 不在本包内，需另行安装。本发布版不包含 apfs_aligned.efi，对应配置已禁用；整理后的公开副本没有单独进行启动验证。

接力、通用剪贴板、随航等功能本轮未验证，不能从隔空投送成功推断其可用。

## 校验

发行 ZIP 附有独立 SHA-256 文件。解压后可在目录中执行：

```bash
shasum -a 256 -c SHA256SUMS.txt
plutil -lint EFI/OC/config.plist
```

本版已检查文件哈希、plist 语法、启用路径、文档链接及脚本语法。这些检查不能代替实际启动和功能验收。配置、文档和脚本沿用仓库 MIT 许可，第三方组件保留各自作者和许可证，详见 THIRD_PARTY_LICENSES.md。
