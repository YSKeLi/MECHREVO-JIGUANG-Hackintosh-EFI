#!/bin/bash
# Intel 核显状态采样：每 3 秒一次，共 10 分钟
# 输出到 $HOME/igpu-diag/boot-<时间>.log
# 用法：bash scripts/igpu-diag.sh
DIR="$HOME/igpu-diag"
mkdir -p "$DIR"
LOG="$DIR/boot-$(date +%Y%m%d-%H%M%S).log"

{
  echo "======== 诊断开始 $(date '+%Y-%m-%d %H:%M:%S') ========"
  echo "macOS: $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
  echo "boot-args: $(nvram boot-args 2>/dev/null | sed 's/^boot-args[[:space:]]*//')"
  echo
  echo "---- 启动期内核日志 ----"
  log show --last 3m --predicate 'senderImagePath CONTAINS "AppleIntelTGL" OR senderImagePath CONTAINS "WhateverXe" OR eventMessage CONTAINS "TGL"' 2>/dev/null | head -60
} >> "$LOG" 2>/dev/null

for i in $(seq 1 200); do
    T=$(date '+%H:%M:%S')
    ACCEL=$(ioreg -w0 -c IntelAccelerator 2>/dev/null | grep -c 'class IntelAccelerator')
    FB=$(ioreg -w0 -c AppleIntelFramebufferController 2>/dev/null | grep -c 'class AppleIntelFramebufferController')
    DISP=$(ioreg -w0 -c AppleDisplay 2>/dev/null | grep -c 'class AppleDisplay')
    WS=$(pgrep -x WindowServer >/dev/null 2>&1 && echo up || echo DOWN)
    printf '[%s] accel=%s fb=%s disp=%s WS=%s\n' "$T" "$ACCEL" "$FB" "$DISP" "$WS" >> "$LOG"
    sleep 3
done
