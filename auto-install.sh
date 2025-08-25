#!/bin/bash
set -e # Exit immediately on error

# ─────────────────────────────────────────────
#  Configuration
# ─────────────────────────────────────────────
DISTRO="Arch-Hyprland"
GITHUB_URL="https://github.com/hetfs/Arch-hyprland.git"
DISTRO_DIR="$HOME/$DISTRO"
INSTALL_SCRIPT="install.sh"

# Colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 3)[WARN]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
YELLOW="$(tput setaf 3)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

# ─────────────────────────────────────────────
#  Functions
# ─────────────────────────────────────────────

print_banner() {
  echo -e "${MAGENTA}"
  echo "╔═════════════════════════════════════════════════════════╗"
  echo "║              ARCH-HYPRLAND INSTALLER SETUP              ║"
  echo "╚═════════════════════════════════════════════════════════╝"
  echo -e "${RESET}"
}

log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

check_git() {
  if ! command -v git &>/dev/null; then
    echo "${INFO} Git not found! ${SKY_BLUE}Installing Git...${RESET}"
    if ! sudo pacman -S --noconfirm git; then
      echo "${ERROR} Failed to install Git. Exiting."
      exit 1
    fi
    echo "${OK} Git installed successfully"
  else
    echo "${OK} Git is already installed"
  fi
}

check_existing_installation() {
  if [[ -d "$DISTRO_DIR" ]]; then
    echo "${NOTE} Existing installation found at: $DISTRO_DIR"
    if whiptail --title "Update Existing Installation" --yesno \
      "A previous installation was found at:\n$DISTRO_DIR\n\nDo you want to update it?" 10 60; then
      update_repo
    else
      echo "${INFO} Keeping existing installation. Exiting."
      exit 0
    fi
  else
    clone_repo
  fi
}

update_repo() {
  echo "${YELLOW}Updating repository at $DISTRO_DIR...${RESET}"

  cd "$DISTRO_DIR" || {
    echo "${ERROR} Cannot access directory: $DISTRO_DIR"
    exit 1
  }

  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "${ERROR} Not a git repository: $DISTRO_DIR"
    exit 1
  fi

  # Stash any local changes
  if ! git diff --quiet; then
    echo "${WARN} Local changes detected. Stashing changes...${RESET}"
    git stash
  fi

  # Fetch and update
  if git fetch --all; then
    if git pull --rebase; then
      echo "${OK} Repository updated successfully"
    else
      echo "${WARN} Pull with rebase failed. Trying hard reset...${RESET}"
      git reset --hard origin/main || {
        echo "${ERROR} Could not update repository."
        exit 1
      }
      echo "${OK} Repository reset to origin/main"
    fi
  else
    echo "${ERROR} Failed to fetch updates"
    exit 1
  fi

  # Apply stashed changes if any
  if git stash list | grep -q "stash@"; then
    echo "${INFO} Applying stashed changes...${RESET}"
    git stash pop
  fi
}

clone_repo() {
  echo "${MAGENTA}Cloning repository into $DISTRO_DIR...${RESET}"

  if ! git clone --depth=1 --branch=main "$GITHUB_URL" "$DISTRO_DIR"; then
    echo "${ERROR} Failed to clone repository from $GITHUB_URL"
    echo "${NOTE} Check your internet connection and repository URL"
    exit 1
  fi

  cd "$DISTRO_DIR" || {
    echo "${ERROR} Cannot access cloned directory: $DISTRO_DIR"
    exit 1
  }

  echo "${OK} Repository cloned successfully"
}

verify_install_script() {
  if [[ ! -f "$INSTALL_SCRIPT" ]]; then
    echo "${ERROR} Install script '$INSTALL_SCRIPT' not found in: $DISTRO_DIR"
    exit 1
  fi

  if [[ ! -x "$INSTALL_SCRIPT" ]]; then
    echo "${INFO} Making install script executable...${RESET}"
    chmod +x "$INSTALL_SCRIPT" || {
      echo "${ERROR} Cannot make install script executable"
      exit 1
    }
  fi

  echo "${OK} Install script verified and ready"
}

run_installer() {
  echo "${INFO} Starting installation process...${RESET}"

  if whiptail --title "Confirmation" --yesno \
    "Ready to run the installation script?\n\nThis will install Arch-Hyprland on your system." 10 60; then
    echo "${SKY_BLUE}Launching installer...${RESET}"
    ./"$INSTALL_SCRIPT"
  else
    echo "${INFO} Installation cancelled by user"
    exit 0
  fi
}

cleanup() {
  echo "${INFO} Cleaning up...${RESET}"
  # Add any cleanup operations here if needed
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# ─────────────────────────────────────────────
#  Main Execution
# ─────────────────────────────────────────────
main() {
  print_banner
  printf "\n"

  echo "${NOTE} Starting Arch-Hyprland setup process${RESET}"

  # Check and install git if needed
  check_git
  printf "\n"

  # Handle repository setup
  check_existing_installation
  printf "\n"

  # Verify install script
  verify_install_script
  printf "\n"

  # Run the installer
  run_installer

  echo "${OK} Setup process completed successfully${RESET}"
}

# Run main function
main "$@"
