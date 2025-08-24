#!/bin/bash
set -euo pipefail

clear

# ─────────────────────────────────────────────
#  Colors & UI helpers
# ─────────────────────────────────────────────
readonly OK="$(tput setaf 2)[OK]$(tput sgr0)"
readonly ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
readonly NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
readonly INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
readonly WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
readonly ACTION="$(tput setaf 6)[ACTION]$(tput sgr0)"
readonly MAGENTA="$(tput setaf 5)"
readonly YELLOW="$(tput setaf 3)"
readonly CYAN="$(tput setaf 6)"
readonly RESET="$(tput sgr0)"

# Temporary files
readonly PACKAGE_LIST="/tmp/selected_packages.txt"
readonly DIRECTORY_LIST="/tmp/selected_directories.txt"

# Cleanup function
cleanup() {
  rm -f "$PACKAGE_LIST" "$DIRECTORY_LIST" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

# ─────────────────────────────────────────────
#  Functions
# ─────────────────────────────────────────────
print_banner() {
  printf "\n%.0s" {1..2}
  echo -e "\e[35m
╔═════════════════════════════════════════════════════════╗
║         ⚠️  ARCH - HYPRLAND UNINSTALLER ⚠️              ║
║                                                         ║
║         This will remove your Hyprland setup!           ║
╚═════════════════════════════════════════════════════════╝
\e[0m"
  printf "\n"
}

log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

remove_packages() {
  local list=$1
  local removed_count=0
  local error_count=0

  while read -r pkg; do
    [[ -z "$pkg" ]] && continue

    if pacman -Qi "$pkg" &>/dev/null; then
      echo "$ACTION Removing package: ${CYAN}$pkg${RESET}"
      if sudo pacman -Rns --noconfirm "$pkg" 2>/dev/null; then
        echo "$OK Successfully removed: ${CYAN}$pkg${RESET}"
        ((removed_count++))
      else
        echo "$ERROR Failed to remove: ${CYAN}$pkg${RESET}"
        ((error_count++))
      fi
    else
      echo "$INFO Package ${YELLOW}$pkg${RESET} not installed. Skipping."
    fi
  done <"$list"

  echo "$NOTE Removed $removed_count packages, $error_count errors"
}

remove_directories() {
  local list=$1
  local removed_count=0
  local error_count=0

  while read -r dir; do
    [[ -z "$dir" ]] && continue
    local target="$HOME/.config/$dir"

    if [ -d "$target" ]; then
      echo "$ACTION Removing directory: ${CYAN}$target${RESET}"
      if rm -rf "$target" 2>/dev/null; then
        echo "$OK Successfully removed: ${CYAN}$target${RESET}"
        ((removed_count++))
      else
        echo "$ERROR Failed to remove: ${CYAN}$target${RESET}"
        ((error_count++))
      fi
    else
      echo "$INFO Directory ${YELLOW}$target${RESET} not found. Skipping."
    fi
  done <"$list"

  echo "$NOTE Removed $removed_count directories, $error_count errors"
}

check_dependencies() {
  if ! command -v whiptail >/dev/null 2>&1; then
    echo "$ERROR whiptail is required but not installed. Please install libnewt."
    exit 1
  fi
}

# ─────────────────────────────────────────────
#  Main execution
# ─────────────────────────────────────────────
main() {
  # Create log file
  readonly LOG_DIR="${HOME}/.hyprland-uninstall-logs"
  readonly LOG_FILE="${LOG_DIR}/uninstall-$(date +%Y%m%d-%H%M%S).log"
  mkdir -p "$LOG_DIR"

  print_banner
  check_dependencies

  # Initial confirmation
  if ! whiptail --title "Arch-Hyprland Uninstall Script" --yesno \
    "This script will uninstall Hyprland packages and configurations.

🔧 You can choose which packages and directories to remove
📁 Configs under ~/.config will be affected
⚠️  WARNING: After uninstallation, your system may become unstable

Do you want to continue?" 16 80; then
    echo "$INFO Uninstall process canceled."
    exit 0
  fi

  # Package selection
  local packages=(
    "btop" "Resource monitor" "OFF"
    "brightnessctl" "Brightness control" "OFF"
    "cava" "Audio visualizer" "OFF"
    "cliphist" "Clipboard manager" "OFF"
    "fastfetch" "System information tool" "OFF"
    "ffmpegthumbnailer" "Video thumbnail generator" "OFF"
    "grim" "Screenshot tool" "OFF"
    "imagemagick" "Image manipulation" "OFF"
    "kitty" "Terminal emulator" "OFF"
    "kvantum" "Qt theming engine" "OFF"
    "mousepad" "Text editor" "OFF"
    "mpv" "Media player" "OFF"
    "mpv-mpris" "MPRIS plugin for MPV" "OFF"
    "network-manager-applet" "Network manager" "OFF"
    "nvtop" "GPU monitoring tool" "OFF"
    "nwg-displays" "Display configuration" "OFF"
    "nwg-look" "GTK settings manager" "OFF"
    "pamixer" "PulseAudio mixer" "OFF"
    "pokemon-colorscripts-git" "Terminal color scripts" "OFF"
    "pavucontrol" "Audio control" "OFF"
    "playerctl" "Media player control" "OFF"
    "pyprland" "Hyprland Python utilities" "OFF"
    "qalculate-gtk" "Calculator" "OFF"
    "qt5ct" "Qt5 configuration" "OFF"
    "qt6ct" "Qt6 configuration" "OFF"
    "quickshell" "Desktop overview utility" "OFF"
    "rofi-wayland" "Application launcher" "OFF"
    "slurp" "Region selection tool" "OFF"
    "swappy" "Screenshot editor" "OFF"
    "swaync" "Notification center" "OFF"
    "swww" "Wallpaper engine" "OFF"
    "thunar" "File manager" "OFF"
    "thunar-archive-plugin" "Archive plugin" "OFF"
    "thunar-volman" "Volume management" "OFF"
    "tumbler" "Thumbnail service" "OFF"
    "wallust" "Color palette generator" "OFF"
    "waybar" "Wayland bar" "OFF"
    "wl-clipboard" "Wayland clipboard" "OFF"
    "wlogout" "Logout menu" "OFF"
    "xdg-desktop-portal-hyprland" "File picker portal" "OFF"
    "yad" "Dialog boxes" "OFF"
    "yt-dlp" "Video downloader" "OFF"
    "xarchiver" "Archive manager" "OFF"
    "hypridle" "Idle daemon" "OFF"
    "hyprlock" "Lock screen" "OFF"
    "hyprpolkitagent" "Polkit agent" "OFF"
    "hyprland" "Window manager" "OFF"
  )

  local package_choices=$(whiptail --title "Select Packages to Uninstall" --checklist \
    "Select packages to remove (Space to toggle, Tab to navigate):" 35 90 25 \
    "${packages[@]}" 3>&1 1>&2 2>&3) || true

  if [ -z "$package_choices" ]; then
    echo "$INFO No packages selected for removal."
    return 1
  fi

  echo "$package_choices" | tr -d '"' | tr ' ' '\n' >"$PACKAGE_LIST"

  # Directory selection
  local directories=(
    "hypr" "Hyprland configuration" "OFF"
    "waybar" "Waybar configuration" "OFF"
    "kitty" "Kitty terminal configuration" "OFF"
    "rofi" "Rofi launcher configuration" "OFF"
    "swaync" "Notification configuration" "OFF"
    "thunar" "Thunar file manager configuration" "OFF"
    "fastfetch" "Fastfetch configuration" "OFF"
    "swww" "Wallpaper configuration" "OFF"
  )

  local dir_choices=$(whiptail --title "Select Config Directories to Remove" --checklist \
    "Select config directories to remove from ~/.config/:" 20 80 15 \
    "${directories[@]}" 3>&1 1>&2 2>&3) || true

  if [ -n "$dir_choices" ]; then
    echo "$dir_choices" | tr -d '"' | tr ' ' '\n' >"$DIRECTORY_LIST"
  fi

  # Final confirmation
  local package_count=$(wc -l <"$PACKAGE_LIST")
  local dir_count=0
  [ -f "$DIRECTORY_LIST" ] && dir_count=$(wc -l <"$DIRECTORY_LIST")

  if ! whiptail --title "Final Confirmation" --yesno \
    "Ready to uninstall:\n\n📦 $package_count packages\n📁 $dir_count config directories\n\n⚠️  WARNING: This action is irreversible!\n\nProceed with uninstallation?" \
    14 80; then
    echo "$INFO Uninstall process canceled."
    exit 0
  fi

  # Execution
  echo
  echo "$NOTE ${CYAN}Starting package removal...${RESET}"
  remove_packages "$PACKAGE_LIST"

  if [ -f "$DIRECTORY_LIST" ] && [ -s "$DIRECTORY_LIST" ]; then
    echo
    echo "$NOTE ${CYAN}Removing config directories...${RESET}"
    remove_directories "$DIRECTORY_LIST"
  fi

  # Final message
  echo
  echo -e "${MAGENTA}╔═════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${MAGENTA}║                 UNINSTALLATION COMPLETE                 ║${RESET}"
  echo -e "${MAGENTA}╚═════════════════════════════════════════════════════════╝${RESET}"
  echo
  echo -e "$INFO Selected Hyprland components have been removed"
  echo -e "$WARN Some orphaned packages might remain. Run: ${CYAN}sudo pacman -Rns \$(pacman -Qdtq)${RESET}"
  echo -e "$ACTION ${YELLOW}Recommended: Reboot your system for changes to take effect${RESET}"
  echo
}

# Run main function
main "$@"
