#!/usr/bin/env bash
# Kill running bar instances, then start one per monitor
killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.2; done

if type xrandr >/dev/null 2>&1; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload main &
  done
else
  polybar --reload main &
fi
