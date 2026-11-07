#!/bin/bash
# 激活内屏（混合模式）— 2026-11-07 修正版
#
# 原理：
#   核显驱动在开机时假设固件已训练好 eDP 链路，于是【跳过链路训练】，
#   结果是背光点亮、系统正常渲染，但面板收不到有效信号 → 只有背光没有画面。
#   一次【极短的】休眠→唤醒会强制驱动重走完整初始化，从而点亮面板。
#
# 关键：Doze 必须 ≤2 秒
#     实测 1.0 秒 → 成功
#     实测 1.6 秒 → 成功
#     实测 5.8 秒 → 失败
#     实测 20 秒以上 → 失败，并出现 DBUF 电源井超时
#
#   长 Doze 会让面板深度断电，唤醒时必须重新训练链路，
#   而训练需要 AUX —— AUX 在这台机器上不通，训练失败后驱动把显示下线
#   （FB0 is not enabled），此后只能重启恢复。
#
# 注意：
#   caffeinate -u 只是"阻止系统休眠"，它【不能】唤醒已经睡着的显示器。
#   唤醒必须靠真实按键 —— 本脚本尝试用 osascript 模拟空格，
#   如果系统没给"辅助功能"权限就会失败，此时请手动按一下空格。
#
# 用法：bash scripts/激活内屏.sh      （普通用户即可，不需要 sudo）

set -u

echo "==> 让显示器休眠"
pmset displaysleepnow 2>&1 | grep -v '^$' || true

echo "==> 立即唤醒（尽快缩短 Doze）"
if ! osascript -e 'tell application "System Events" to key code 49' >/dev/null 2>&1; then
  echo '    （模拟按键失败：可能没给"系统事件"辅助功能权限）'
  echo "    >>> 请立刻手动按一下空格键 <<<"
fi

sleep 1

echo
echo "==> 结果检查"
LOGS=$(log show --last 1m --predicate 'senderImagePath CONTAINS "IntelTGLGraphicsFramebuffer"' 2>/dev/null)
NFAIL=$(printf '%s\n' "$LOGS" | grep -c 'link training failed')
NDIS=$(printf '%s\n' "$LOGS" | grep -c 'FB0 is not enabled')

echo "    链路训练失败: $NFAIL 次"
echo "    FB0 被禁用  : $NDIS 次"
if [ "$NFAIL" = "0" ] && [ "$NDIS" = "0" ]; then
  echo "    ✅ 面板应该已点亮"
  echo "    内屏归属:"
  ioreg -l -w0 2>/dev/null | grep 'IODisplayPrefsKey" =' | sed 's/.*= //' \
    | grep -oE 'IGPU@2|PEGP@0' | sort -u | sed 's/^/      /'
else
  echo "    ❌ Doze 时间太长了。请重启后重试，休眠后【立即】按键。"
fi
