#!/usr/bin/env bash

# ===== CONFIG =====
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
VIDEO_DIR="$HOME/Videos/Recordings"
TMP_IMG="/tmp/screenshot.png"
RECORD_PID="/tmp/ffmpeg_screen_record.pid"
DISPLAY=":0.0"
RESOLUTION="1920x1080"
FPS="30"
ROFI_DELAY="0.3"
FFMPEG_OPTS=(
  -c:v libx264
  -pix_fmt yuv420p
  -profile:v baseline
  -level 3.0
  -movflags +faststart
)

mkdir -p "$SCREENSHOT_DIR" "$VIDEO_DIR"

# ===== MENU =====
OPTIONS=(
  "Screenshot (Full)"
  "Screenshot (Selection)"
  "Screenshot (Selection → Clipboard)"
  "Record Screen (Full)"
  "Record Screen (Selection)"
  "Stop Screen Recording"
)

CHOICE=$(printf '%s\n' "${OPTIONS[@]}" | rofi -dmenu -i -p "Screen Tools")

TIMESTAMP=$(date +"%Y-%m-%d-%T")

case "$CHOICE" in
  "Screenshot (Full)")
    sleep "$ROFI_DELAY"
    scrot "$SCREENSHOT_DIR/$TIMESTAMP-screenshot.png"
    notify-send "Screenshot saved" "$SCREENSHOT_DIR/$TIMESTAMP-screenshot.png"
    ;;

  "Screenshot (Selection)")
    sleep "$ROFI_DELAY"
    scrot -s "$SCREENSHOT_DIR/$TIMESTAMP-screenshot.png"
    notify-send "Screenshot saved" "$SCREENSHOT_DIR/$TIMESTAMP-screenshot.png"
    ;;

  "Screenshot (Selection → Clipboard)")
    sleep "$ROFI_DELAY"
    scrot -s -f -o "$TMP_IMG" && \
      xclip -selection clipboard -t image/png -i "$TMP_IMG"
    notify-send "Screenshot copied to clipboard"
    ;;

  "Record Screen (Full)")
    if [[ -f "$RECORD_PID" ]]; then
      notify-send "Recording already running"
      exit 0
    fi

    ffmpeg -f x11grab \
      -video_size "$RESOLUTION" \
      -framerate "$FPS" \
      -i "$DISPLAY" \
      "${FFMPEG_OPTS[@]}" \
      "$VIDEO_DIR/$TIMESTAMP-recording.mp4" \
      >/dev/null 2>&1 &

    echo $! > "$RECORD_PID"
    notify-send "Screen recording started (full screen)"
    ;;
  "Record Screen (Selection)")
    if [[ -f "$RECORD_PID" ]]; then
      notify-send "Recording already running"
      exit 0
    fi

    GEOM=$(slop -f "%x %y %w %h") || exit 1
    read X Y W H <<< "$GEOM"

    W=$((W / 2 * 2))
    H=$((H / 2 * 2))

    ffmpeg -f x11grab \
      -video_size "${W}x${H}" \
      -framerate "$FPS" \
      -i "$DISPLAY+$X,$Y" \
      "${FFMPEG_OPTS[@]}" \
      "$VIDEO_DIR/$TIMESTAMP-recording.mp4" \
      >/dev/null 2>&1 &

    echo $! > "$RECORD_PID"
    notify-send "Screen recording started (selection)"
    ;;
  "Stop Screen Recording")
    if [[ -f "$RECORD_PID" ]]; then
      kill "$(cat "$RECORD_PID")"
      rm "$RECORD_PID"

      if [[ -f /tmp/record_target ]]; then
        xclip -selection clipboard -t video/mp4 -i "$TMP_VIDEO"
        rm /tmp/record_target
        notify-send "Recording copied to clipboard"
      else
        notify-send "Screen recording saved"
      fi
    else
      notify-send "No recording running"
    fi
    ;;
esac
