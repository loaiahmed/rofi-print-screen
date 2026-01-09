#!/usr/bin/env bash

RECORD_PID="/tmp/ffmpeg_screen_record.pid"
START_TIME_FILE="/tmp/record_start_time"

if [[ -f "$RECORD_PID" ]] && kill -0 "$(cat "$RECORD_PID")" 2>/dev/null; then
  if [[ -f "$START_TIME_FILE" ]]; then
    START=$(cat "$START_TIME_FILE")
    NOW=$(date +%s)
    ELAPSED=$((NOW - START))

    MIN=$((ELAPSED / 60))
    SEC=$((ELAPSED % 60))

    TIME_FMT=$(printf "%02d:%02d" "$MIN" "$SEC")
  else
    TIME_FMT="00:00"
  fi

  echo "⏺ REC $TIME_FMT"
  echo "⏺ $TIME_FMT"
  echo "#ff5555"
else
  exit 0
fi

