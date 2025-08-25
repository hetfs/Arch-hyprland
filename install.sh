#!/bin/bash

# ╔════════════════════════════════════════════════════════════╗
# ║             ARCH - HYPRLAND INSTALL SCRIPT                 ║
# ║       Repo: https://github.com/hetfs/Arch-hyprland         ║
# ╚════════════════════════════════════════════════════════════╝

#################################################################
# 🚀 Arch-Hyprland Auto Setup
#
# Automate your perfect Arch-Hyprland environment.
# Pre-configured, polished, and ready to fly in minutes.
# Builds a battle-tested Hyprland desktop on Arch Linux with:
#   ✔️ Core packages & dependencies
#   ✔️ Wayland compositing (Hyprland)
#   ✔️ Keybinds, gestures & workspace tweaks
#   ✔️ Fonts, theming & dotfiles integration
#   ✔️ Developer-ready tools
#
# Run this script on a fresh Arch system to bootstrap everything.
###################################################################

set -e # Exit on any error
set -u # Treat unset variables as errors

clear

# Color definitions
readonly OK="$(tput setaf 2)[OK]$(tput sgr0)"
readonly ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
readonly NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
readonly INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
readonly WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
readonly CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
readonly MAGENTA="$(tput setaf 5)"
readonly ORANGE="$(tput setaf 214)"
readonly WARNING="$(tput setaf 1)"
readonly YELLOW="$(tput setaf 3)"
readonly GREEN="$(tput setaf 2)"
readonly BLUE="$(tput setaf 4)"
readonly SKY_BLUE="$(tput setaf 6)"
readonly RESET="$(tput sgr0)"

# Create Directory for Install Logs
readonly LOG_DIR="Install-Logs"
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
fi

# Set the name of the log file
readonly LOG="$LOG_DIR/01-Hyprland-Install-Scripts-$(date +%d-%H%M%S).log"

# Logging function
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG"
}

# Check if running as root
check_root() {
  if [[ $EUID -eq 0 ]]; then
    log_message "${ERROR} This script should ${WARNING}NOT${RESET} be executed as root!! Exiting......."
    printf "\n%.0s" {1..2}
    exit 1
  fi
}

# Check if PulseAudio is installed
check_pulseaudio() {
  if pacman -Qq | grep -qw '^pulseaudio$'; then
    log_message "$ERROR PulseAudio is detected as installed. Uninstall it first or edit install.sh on line 211 (execute_script 'pipewire.sh')."
    printf "\n%.0s" {1..2}
    exit 1
  fi
}

# Check and install base-devel
install_base_devel() {
  if pacman -Q base-devel &>/dev/null; then
    log_message "base-devel is already installed."
  else
    log_message "$NOTE Install base-devel.........."
    if sudo pacman -S --noconfirm base-devel; then
      log_message "👌 ${OK} base-devel has been installed successfully."
    else
      log_message "❌ $ERROR base-devel not found nor cannot be installed."
      log_message "$ACTION Please install base-devel manually before running this script... Exiting"
      exit 1
    fi
  fi
}

# Install whiptail if not present
install_whiptail() {
  if ! command -v whiptail >/dev/null; then
    log_message "${NOTE} - whiptail is not installed. Installing..."
    sudo pacman -S --noconfirm libnewt
    printf "\n%.0s" {1..1}
  fi
}

# Install pciutils if not present
install_pciutils() {
  if ! pacman -Qs pciutils >/dev/null; then
    log_message "${NOTE} - pciutils is not installed. Installing..."
    sudo pacman -S --noconfirm pciutils
    printf "\n%.0s" {1..1}
  fi
}

# Function to execute a script
execute_script() {
  local script="$1"
  local script_path="$script_directory/$script"

  if [ -f "$script_path" ]; then
    chmod +x "$script_path"
    if [ -x "$script_path" ]; then
      log_message "Executing script: $script"
      env "$script_path"
    else
      log_message "Failed to make script '$script' executable."
    fi
  else
    log_message "Script '$script' not found in '$script_directory'."
  fi
}

# Function to load preset file
load_preset() {
  if [ -f "$1" ]; then
    log_message "✅ Loading preset: $1"
    source "$1"
  else
    log_message "⚠️ Preset file not found: $1. Using default values."
  fi
}

# Check if any login services are running
check_services_running() {
  local services=("gdm.service" "gdm3.service" "lightdm.service" "lxdm.service")
  active_services=()

  for svc in "${services[@]}"; do
    if systemctl is-active --quiet "$svc"; then
      active_services+=("$svc")
    fi
  done

  return $((${#active_services[@]} > 0 ? 0 : 1))
}

# Main execution
main() {
  check_root
  check_pulseaudio
  install_base_devel
  install_whiptail

  clear

  printf "\n%.0s" {1..2}
  echo -e "\e[35m
   =======================================================
                ARCH - HYPRLAND INSTALL SCRIPT
   =======================================================
    \e[0m"
  printf "\n%.0s" {1..1}

  # Welcome message
  whiptail --title "ARCH - HYPRLAND INSTALL SCRIPT" \
    --msgbox "WELCOME TO ARCH - HYPRLAND INSTALL SCRIPT!!!\n\n\
 ATTENTION: Run a full system update and Reboot first (Highly Recommended).\n\n\
 NOTE: On VMs, enable 3D acceleration or Hyprland may NOT start!" \
    15 80

  # Ask if the user wants to proceed
  if ! whiptail --title "Proceed with Installation?" --yesno "Would you like to proceed?" 7 50; then
    log_message "❌ ${INFO} You 🫵 chose ${YELLOW}NOT${RESET} to proceed. ${YELLOW}Exiting...${RESET}"
    echo -e "\n"
    exit 1
  fi

  log_message "👌 ${OK} 🇬🇭 ${MAGENTA}HETFS${RESET} ${SKY_BLUE}lets continue with the installation...${RESET}"
  sleep 1
  printf "\n%.0s" {1..1}

  install_pciutils

  # Path to the install-scripts directory
  readonly script_directory="install-scripts"

  # Default values for options
  local gtk_themes="OFF"
  local bluetooth="OFF"
  local thunar="OFF"
  local quickshell="OFF"
  local sddm="OFF"
  local sddm_theme="OFF"
  local xdph="OFF"
  local zsh="OFF"
  local pokemon="OFF"
  local rog="OFF"
  local dots="OFF"
  local input_group="OFF"
  local nvidia="OFF"
  local nouveau="OFF"

  # Load preset if specified
  if [[ "${1:-}" == "--preset" && -n "${2:-}" ]]; then
    load_preset "$2"
  fi

  # Check for AUR helper
  local aur_helper=""
  if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    log_message "${CAT} - Neither yay nor paru found. Asking 🗣️ USER to select..."
    while true; do
      aur_helper=$(whiptail --title "Neither Yay nor Paru is installed" --checklist \
        "Neither Yay nor Paru is installed. Choose one AUR.\n\nNOTE: Select only 1 AUR helper!\nINFO: spacebar to select" 12 60 2 \
        "yay" "AUR Helper yay" "OFF" \
        "paru" "AUR Helper paru" "OFF" \
        3>&1 1>&2 2>&3)

      if [ $? -ne 0 ]; then
        log_message "❌ ${INFO} You cancelled the selection. ${YELLOW}Goodbye!${RESET}"
        exit 0
      fi

      if [ -z "$aur_helper" ]; then
        whiptail --title "Error" --msgbox "You must select at least one AUR helper to proceed." 10 60 2
        continue
      fi

      aur_helper=$(echo "$aur_helper" | tr -d '"' | tr -s ' ')

      if [[ $(echo "$aur_helper" | wc -w) -ne 1 ]]; then
        whiptail --title "Error" --msgbox "You must select exactly one AUR helper." 10 60 2
        continue
      else
        break
      fi
    done
    log_message "${INFO} - You selected: $aur_helper as your AUR helper"
  else
    log_message "${NOTE} - AUR helper is already installed. Skipping AUR helper selection."
  fi

  # Check for active login managers
  if check_services_running; then
    local active_list=$(printf "%s\n" "${active_services[@]}")
    whiptail --title "Active non-SDDM login manager(s) detected" \
      --msgbox "The following login manager(s) are active:\n\n$active_list\n\nIf you want to install SDDM and SDDM theme, stop and disable the active services above, reboot before running this script\n\nYour option to install SDDM and SDDM theme has now been removed\n\n- Ja " 23 80
  fi

  # Check for NVIDIA GPU
  local nvidia_detected=false
  if lspci | grep -i "nvidia" &>/dev/null; then
    nvidia_detected=true
    whiptail --title "NVIDIA GPU Detected" --msgbox "NVIDIA GPU detected in your system.\n\nNOTE: The script will install nvidia-dkms, nvidia-utils, and nvidia-settings if you chose to configure." 12 60
  fi

  # Check for input group
  local input_group_detected=false
  if ! groups "$(whoami)" | grep -q '\binput\b'; then
    input_group_detected=true
    whiptail --title "Input Group" --msgbox "You are not currently in the input group.\n\nAdding you to the input group might be necessary for the Waybar keyboard-state functionality." 12 60
  fi

  # Build options array
  local options_command=(
    whiptail --title "Select Options" --checklist "Choose options to install or configure\nNOTE: 'SPACEBAR' to select & 'TAB' key to change selection" 28 85 20
  )

  # Add NVIDIA options if detected
  if [ "$nvidia_detected" == "true" ]; then
    options_command+=(
      "nvidia" "Do you want script to configure NVIDIA GPU?" "OFF"
      "nouveau" "Do you want Nouveau to be blacklisted?" "OFF"
    )
  fi

  # Add input group option if needed
  if [ "$input_group_detected" == "true" ]; then
    options_command+=(
      "input_group" "Add your USER to input group for some waybar functionality?" "OFF"
    )
  fi

  # Add SDDM options if no active login manager
  if ! check_services_running; then
    options_command+=(
      "sddm" "Install & configure SDDM login manager?" "OFF"
      "sddm_theme" "Download & Install Additional SDDM theme?" "OFF"
    )
  fi

  # Add remaining options
  options_command+=(
    "gtk_themes" "Install GTK themes? (required for Dark/Light function)" "OFF"
    "bluetooth" "Do you want script to configure Bluetooth?" "OFF"
    "thunar" "Do you want Thunar file manager to be installed?" "OFF"
    "quickshell" "Install quickshell for Desktop-Like Overview?" "OFF"
    "xdph" "Install XDG-DESKTOP-PORTAL-HYPRLAND (for screen share)?" "OFF"
    "zsh" "Install zsh shell with Oh-My-Zsh?" "OFF"
    "pokemon" "Add Pokemon color scripts to your terminal?" "OFF"
    "rog" "Are you installing on Asus ROG laptops?" "OFF"
    "dots" "Download and install pre-configured HETFS Hyprland dotfiles?" "OFF"
  )

  # Get selected options
  local selected_options=""
  while true; do
    selected_options=$("${options_command[@]}" 3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
      log_message "❌ ${INFO} You 🫵 cancelled the selection. ${YELLOW}Goodbye!${RESET}"
      exit 0
    fi

    if [ -z "$selected_options" ]; then
      whiptail --title "Warning" --msgbox "No options were selected. Please select at least one option." 10 60
      continue
    fi

    selected_options=$(echo "$selected_options" | tr -d '"' | tr -s ' ')
    IFS=' ' read -r -a options <<<"$selected_options"

    # Check if dots option was selected
    local dots_selected="OFF"
    for option in "${options[@]}"; do
      if [[ "$option" == "dots" ]]; then
        dots_selected="ON"
        break
      fi
    done

    if [[ "$dots_selected" == "OFF" ]]; then
      if ! whiptail --title "KooL Hyprland Dot Files" --yesno \
        "You have not selected to install the pre-configured KooL Hyprland dotfiles.\n\nKindly NOTE that if you proceed without Dots, Hyprland will start with default vanilla Hyprland configuration and I won't be able to give you support.\n\nWould you like to continue install without KooL Hyprland Dots or return to choices/options?" \
        --yes-button "Continue" --no-button "Return" 15 90; then
        log_message "🔙 Returning to options..."
        continue
      else
        log_message "${INFO} ⚠️ Continuing WITHOUT the dotfiles installation..."
        printf "\n%.0s" {1..1}
      fi
    fi

    # Confirmation
    local confirm_message="You have selected the following options:\n\n"
    for option in "${options[@]}"; do
      confirm_message+=" - $option\n"
    done
    confirm_message+="\nAre you happy with these choices?"

    if ! whiptail --title "Confirm Your Choices" --yesno "$(printf "%s" "$confirm_message")" 25 80; then
      log_message "❌ ${SKY_BLUE}You're not 🫵 happy${RESET}. ${YELLOW}Returning to options...${RESET}"
      continue
    fi

    log_message "👌 ${OK} You confirmed your choices. Proceeding with ${SKY_BLUE}HETFS 🇬🇭 Hyprland Installation...${RESET}"
    break
  done

  printf "\n%.0s" {1..1}

  # Execute installation scripts
  execute_script "00-base.sh"
  sleep 1
  execute_script "pacman.sh"
  sleep 1

  # Install AUR helper if selected
  if [ "$aur_helper" == "paru" ]; then
    execute_script "paru.sh"
  elif [ "$aur_helper" == "yay" ]; then
    execute_script "yay.sh"
  fi

  sleep 1

  # Install main components
  log_message "${INFO} Installing ${SKY_BLUE}KooL Hyprland additional packages...${RESET}"
  sleep 1
  execute_script "01-hypr-pkgs.sh"

  log_message "${INFO} Installing ${SKY_BLUE}pipewire and pipewire-audio...${RESET}"
  sleep 1
  execute_script "pipewire.sh"

  log_message "${INFO} Installing ${SKY_BLUE}necessary fonts...${RESET}"
  sleep 1
  execute_script "fonts.sh"

  log_message "${INFO} Installing ${SKY_BLUE}Hyprland...${RESET}"
  sleep 1
  execute_script "hyprland.sh"

  # Process selected options
  for option in "${options[@]}"; do
    case "$option" in
    sddm)
      if check_services_running; then
        local active_list=$(printf "%s\n" "${active_services[@]}")
        whiptail --title "Error" --msgbox "One of the following login services is running:\n$active_list\n\nPlease stop & disable it or DO not choose SDDM." 12 60
        exec "$0"
      else
        log_message "${INFO} Installing and configuring ${SKY_BLUE}SDDM...${RESET}"
        execute_script "sddm.sh"
      fi
      ;;
    nvidia)
      log_message "${INFO} Configuring ${SKY_BLUE}nvidia stuff${RESET}"
      execute_script "nvidia.sh"
      ;;
    nouveau)
      log_message "${INFO} blacklisting ${SKY_BLUE}nouveau${RESET}"
      execute_script "nvidia_nouveau.sh"
      ;;
    gtk_themes)
      log_message "${INFO} Installing ${SKY_BLUE}GTK themes...${RESET}"
      execute_script "gtk_themes.sh"
      ;;
    input_group)
      log_message "${INFO} Adding user into ${SKY_BLUE}input group...${RESET}"
      execute_script "InputGroup.sh"
      ;;
    quickshell)
      log_message "${INFO} Installing ${SKY_BLUE}quickshell for Desktop Overview...${RESET}"
      execute_script "quickshell.sh"
      ;;
    xdph)
      log_message "${INFO} Installing ${SKY_BLUE}xdg-desktop-portal-hyprland...${RESET}"
      execute_script "xdph.sh"
      ;;
    bluetooth)
      log_message "${INFO} Configuring ${SKY_BLUE}Bluetooth...${RESET}"
      execute_script "bluetooth.sh"
      ;;
    thunar)
      log_message "${INFO} Installing ${SKY_BLUE}Thunar file manager...${RESET}"
      execute_script "thunar.sh"
      execute_script "thunar_default.sh"
      ;;
    sddm_theme)
      log_message "${INFO} Downloading & Installing ${SKY_BLUE}Additional SDDM theme...${RESET}"
      execute_script "sddm_theme.sh"
      ;;
    zsh)
      log_message "${INFO} Installing ${SKY_BLUE}zsh with Oh-My-Zsh...${RESET}"
      execute_script "zsh.sh"
      ;;
    pokemon)
      log_message "${INFO} Adding ${SKY_BLUE}Pokemon color scripts to terminal...${RESET}"
      execute_script "zsh_pokemon.sh"
      ;;
    rog)
      log_message "${INFO} Installing ${SKY_BLUE}ROG laptop packages...${RESET}"
      execute_script "rog.sh"
      ;;
    dots)
      log_message "${INFO} Installing pre-configured ${SKY_BLUE}HETFS Hyprland dotfiles...${RESET}"
      execute_script "dotfiles-main.sh"
      ;;
    *)
      log_message "Unknown option: $option"
      ;;
    esac
  done

  sleep 1

  # Copy fastfetch config if needed
  if [ ! -f "$HOME/.config/fastfetch/arch.png" ]; then
    cp -r assets/fastfetch "$HOME/.config/"
  fi

  clear

  # Final check
  execute_script "02-Final-Check.sh"

  printf "\n%.0s" {1..1}

  # Check if Hyprland is installed
  if pacman -Q hyprland &>/dev/null || pacman -Q hyprland-git &>/dev/null; then
    printf "\n ${OK} 👌 Hyprland is installed. However, some essential packages may not be installed. Please see above!"
    printf "\n${CAT} Ignore this message if it states ${YELLOW}All essential packages${RESET} are installed as per above\n"
    sleep 2
    printf "\n%.0s" {1..2}

    printf "${SKY_BLUE}Thank you${RESET} 🫰 for using 🇬🇭 ${MAGENTA}HETFS's Hyprland Dots${RESET}. ${YELLOW}Enjoy and Have a good day!${RESET}"
    printf "\n%.0s" {1..2}

    printf "\n${NOTE} You can start Hyprland by typing ${SKY_BLUE}Hyprland${RESET} (IF SDDM is not installed) (note the capital H!).\n"
    printf "\n${NOTE} However, it is ${YELLOW}highly recommended to reboot${RESET} your system.\n\n"

    while true; do
      echo -n "${CAT} Would you like to reboot now? (y/n): "
      read HYP
      HYP=$(echo "$HYP" | tr '[:upper:]' '[:lower:]')

      case "$HYP" in
      y | yes)
        log_message "${INFO} Rebooting now..."
        systemctl reboot
        break
        ;;
      n | no)
        log_message "👌 ${OK} You chose NOT to reboot"
        printf "\n%.0s" {1..1}
        if lspci | grep -i "nvidia" &>/dev/null; then
          log_message "${INFO} HOWEVER ${YELLOW}NVIDIA GPU${RESET} detected. Reminder that you must REBOOT your SYSTEM..."
          printf "\n%.0s" {1..1}
        fi
        break
        ;;
      *)
        log_message "${WARN} Invalid response. Please answer with 'y' or 'n'."
        ;;
      esac
    done
  else
    log_message "${WARN} Hyprland is NOT installed. Please check 00_CHECK-time_installed.log and other files in the Install-Logs/ directory..."
    printf "\n%.0s" {1..3}
    exit 1
  fi

  printf "\n%.0s" {1..2}
}

# Execute main function with all arguments
main "$@"
