#!/bin/bash
# 历史内屏激活试验（2026-11-16 更新说明）
# 旧组合曾在显示器熄屏后唤醒时出画面，后来相同操作已失效。
# 2026-11-11 黑屏采集显示：链路初次训练成功，随后均衡／符号锁定丢失。
# 因而不能断言驱动从未训练，也不能把 Doze 时长当作唯一成败判据。
# 本脚本只发起一次熄屏／唤醒尝试，不修改配置，不能保证恢复内屏。
# 日志没有匹配错误，不代表物理面板已经显示。
# 用法：bash scripts/激活内屏.sh（普通用户，不需要 sudo）

set -u

printf '%s\n' '历史激活尝试：该方法后来已出现回归，结果需实际观察。'
printf '%s\n' '==> 让显示器熄屏'
if ! pmset displaysleepnow; then
  printf '%s\n' '熄屏命令执行失败，未继续唤醒／诊断。' >&2
  exit 1
fi

printf '%s\n' '==> 尝试唤醒'
if ! osascript -e 'tell application "System Events" to key code 49' >/dev/null 2>&1; then
  printf '%s\n' '模拟按键未成功，请手动按键唤醒；本脚本不自动更改辅助功能权限。'
fi

sleep 1
printf '\n%s\n' '==> 最近一分钟的文本日志（可能包含本次尝试之前的记录）'
if ! panel_logs=$(log show --last 1m --predicate 'senderImagePath CONTAINS "IntelTGLGraphicsFramebuffer"' 2>/dev/null); then
  printf '%s\n' '未能读取日志，无法统计错误。请记录实际画面，按排查文档采集现场。'
  exit 1
fi
panel_failures=$(printf '%s\n' "$panel_logs" | grep -c 'link training failed' || true)
panel_disabled=$(printf '%s\n' "$panel_logs" | grep -c 'FB0 is not enabled' || true)
printf '    链路训练失败匹配: %s 次\n' "$panel_failures"
printf '    FB0 被禁用匹配  : %s 次\n' "$panel_disabled"
printf '%s\n' '以上统计不能判定面板是否出画面，也不能单凭错误推断 Doze 过长。'
printf '%s\n' '请实际观察内屏并记录结果；详见 docs/内屏排查更新-20261116.md。'
