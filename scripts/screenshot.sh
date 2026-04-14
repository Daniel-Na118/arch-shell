#!/usr/bin/env sh

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
SAVE_FILE="$SAVE_DIR/$(date +'%Y-%m-%d_%H-%M-%S')_screenshot.png"

case $1 in
    full)
        grim "$SAVE_FILE"
        ;;
    area)
        grim -g "$(slurp)" "$SAVE_FILE"
        ;;
    window)
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$SAVE_FILE"
        ;;
    *)
        echo "Usage: $0 {full|area|window}"
        exit 1
        ;;
esac

if [ -f "$SAVE_FILE" ]; then
    wl-copy < "$SAVE_FILE"
    notify-send -a "Arch-Shell" -i "$SAVE_FILE" "Screenshot Saved" "Copied to clipboard and saved to $SAVE_FILE"
fi
