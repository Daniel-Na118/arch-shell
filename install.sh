#!/usr/bin/env bash

# Arch-Shell Deployment Script
# Targets: ~/.config/quickshell/arch-shell

SET_COLOR_BLUE="\e[34m"
SET_COLOR_GREEN="\e[32m"
SET_COLOR_YELLOW="\e[33m"
SET_COLOR_RED="\e[31m"
SET_COLOR_RESET="\e[0m"

echo -e "${SET_COLOR_BLUE}🚀 Starting Arch-Shell Deployment...${SET_COLOR_RESET}"

# 1. Define Paths
TARGET_DIR="$HOME/.config/quickshell/arch-shell"
SOURCE_DIR="$(dirname "$(readlink -f "$0")")"

# 2. Check for Dependencies
dependencies=("quickshell" "fd" "grim" "slurp" "wl-copy" "cliphist" "swww" "matugen" "jq" "notify-send")
missing_deps=()

echo -e "\n${SET_COLOR_BLUE}🔍 Checking dependencies...${SET_COLOR_RESET}"
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing_deps+=("$dep")
        echo -e "  [${SET_COLOR_RED}✘${SET_COLOR_RESET}] $dep"
    else
        echo -e "  [${SET_COLOR_GREEN}✔${SET_COLOR_RESET}] $dep"
    fi
done

if [ ${#missing_deps[@]} -ne 0 ]; then
    echo -e "\n${SET_COLOR_YELLOW}⚠️  Warning: Some dependencies are missing. Please install them for full functionality:${SET_COLOR_RESET}"
    echo -e "  sudo pacman -S ${missing_deps[*]}"
fi

# 3. Create Target Directory
echo -e "\n${SET_COLOR_BLUE}📂 Preparing directory: $TARGET_DIR${SET_COLOR_RESET}"
mkdir -p "$TARGET_DIR"

# 4. Copy Files
echo -e "${SET_COLOR_BLUE}📦 Copying files...${SET_COLOR_RESET}"
cp -r "$SOURCE_DIR"/* "$TARGET_DIR/"

# 5. Set Permissions
echo -e "${SET_COLOR_BLUE}🔐 Setting executable permissions...${SET_COLOR_RESET}"
chmod +x "$TARGET_DIR/scripts/screenshot.sh"
find "$TARGET_DIR" -name "*.sh" -exec chmod +x {} +

# 6. Final Instructions
echo -e "\n${SET_COLOR_GREEN}✅ Arch-Shell successfully installed!${SET_COLOR_RESET}"
echo -e "\n${SET_COLOR_YELLOW}To start the shell manually:${SET_COLOR_RESET}"
echo -e "  quickshell -c $TARGET_DIR/shell.qml"

echo -e "\n${SET_COLOR_YELLOW}To launch on Hyprland startup, add this to your hyprland.conf:${SET_COLOR_RESET}"
echo -e "  exec-once = quickshell -c ~/.config/quickshell/arch-shell/shell.qml"

echo -e "\n${SET_COLOR_BLUE}RICE! 🍚${SET_COLOR_RESET}"
