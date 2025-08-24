<p align="center">
  <img src="assets/Arch-banner.png" alt="Arch - Hyprland Install Script Banner" width="800" />
</p>

<h1 align="center">🛠️ Arch - Hyprland Install Script</h1>

<p align="center">
  <a href="https://archlinux.org/">
    <img src="https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white" alt="Arch Linux Badge" />
  </a>
  <a href="https://github.com/hyprwm/Hyprland">
    <img src="https://img.shields.io/badge/Hyprland-00AEEF?style=for-the-badge&logo=wayland&logoColor=white" alt="Hyprland Badge" />
  </a>
 
  <a href="https://github.com/hetfs/Arch-hyprland/stargazers">
    <img src="https://img.shields.io/github/stars/hetfs/Arch-hyprland?style=for-the-badge&logo=github" alt="GitHub Stars Badge" />
  </a>
  <a href="https://github.com/hetfs/Arch-hyprland/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/hetfs/Arch-hyprland?style=for-the-badge" alt="License Badge" />
  </a>
</p>


Automate your perfect **Arch Linux + Hyprland** setup with a polished, production-ready desktop environment. Get from zero to Hyprland in minutes, not hours.

---

## ✨ What This Provides

* ✅ **Complete automated installation** of Arch Linux with Hyprland
* ✅ **Curated package selection** for optimal performance
* ✅ **Centralized dotfile management** from [Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots)
* ✅ **Hardware-aware configuration** (NVIDIA, Intel, AMD support)
* ✅ **Themed components** (SDDM, GTK, icons)

## ⚠️ What This Doesn't Include

* ❌ **Dotfiles/configurations** (pulled from [Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots))
* ❌ **Personal data or customizations**
* ❌ **Manual intervention during installation**

> 📝 **Note**: Screenshots may differ as dotfiles evolve frequently. Check the [Changelog](https://github.com/JaKooLit/Hyprland-Dots-Changelogs) for latest updates.

---

## 🛡️ Pre-Installation Checklist

### 🔐 Backup Your System
**Required**: Use `timeshift` or `snapper` before proceeding.
This script makes significant system changes—having a restore point is essential.

### 🖥️ System Requirements
* **Minimal Arch Linux installation** (base or server type)
* `curl` installed (for automated installation method)
* **Adequate internet connection**
* **User directory ownership** (run from `$HOME` or user-owned directory)

---

## 🎧 Audio Configuration

### Default: PipeWire
This script automatically:
* Installs **PipeWire** as the primary audio server
* Removes and disables **PulseAudio**
* Configures proper audio routing

### Keeping PulseAudio
If you prefer PulseAudio:
1. Edit `install.sh` and comment out the `pipewire.sh` line
2. Or delete `install-scripts/pipewire.sh` before installation

---

## 🎨 Customization Options

### Package Selection
Modify `install-scripts/00-hypr-pkgs.sh` to customize installed packages.

> ⚠️ **Warning**: Breaking dependencies may cause Hyprland-Dots configurations to fail. Test changes in a VM first.

### Theme Management
* **SDDM Themes**: [Modified Fork](https://github.com/JaKooLit/sddm-theme)
* **GTK Themes & Icons**: [Theme Pack](https://github.com/JaKooLit/themes)

---

## 🖥️ Display Manager Setup

### Switching from GDM to SDDM
```bash
# Disable current display manager
sudo systemctl disable gdm.service

# Reboot to TTY
reboot

# After reboot, login via TTY and run:
cd ~/Arch-Hyprlanda
./install.sh
```

During installation, select **SDDM + theme** options.

---

## 🎮 NVIDIA Graphics Support

### Default Installation
* Installs **nvidia-dkms** (supports GTX 900 series and newer)
* Automatic driver configuration
* Optimized environment variables

### Legacy Cards
Edit `install-scripts/nvidia.sh` for older GPU support.

### Nouveau Drivers
Skip NVIDIA option during installation—script automatically blacklists nouveau.

### Troubleshooting NVIDIA Issues

#### SDDM Login Freeze
1. Switch to TTY (`Ctrl + Alt + F2`/`F3`)
2. Identify GPU path:
   ```bash
   lspci -nn
   ls /dev/dri/by-path
   ```
3. Add to `~/.config/hypr/UserConfigs/ENVariables.conf`:
   ```ini
   env = WLR_DRM_DEVICES,/dev/dri/cardX
   ```

#### Recommended NVIDIA Settings
```ini
env = GBM_BACKEND,nvidia-drm
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```

---

## ⚡ Installation Methods

### Automated Installation (Recommended)
```bash
# One-command install (bash/zsh compatible)
sh <(curl -fsSL https://raw.githubusercontent.com/hetfs/Arch-hyprlanda/main/auto-install.sh)
```

> 🐟 **Fish Shell Users**: Use manual installation method below.

### Manual Installation
```bash
# Clone repository
git clone --depth=1 https://github.com/hetfs/Arch-hyprlanda.git ~/Arch-Hyprlanda

# Run installer
cd ~/Arch-Hyprlanda
chmod +x install.sh
./install.sh
```

---

## 🗑️ Uninstallation

### Guided Removal
```bash
./uninstall.sh
```

> ⚠️ **Critical**: Uninstallation may destabilize your system. Always have a `timeshift` or `snapper` backup available before proceeding.

---

## 🔧 Component Management

### Reinstalling Specific Components
Run from the **repository root** (not inside `install-scripts/`):

```bash
# GTK Themes
./install-scripts/gtk-themes.sh

# SDDM Display Manager
./install-scripts/sddm.sh

# Audio Setup
./install-scripts/pipewire.sh

# NVIDIA Drivers
./install-scripts/nvidia.sh
```

> 🚫 **Important**: Never run scripts from within the `install-scripts` directory directly.

---

## ⌨️ Keybindings & Help

* **View Keybinds**: [Hyprland Dots Wiki](https://github.com/JaKooLit/Hyprland-Dots/wiki)
* **In-System Help**: Press `SUPER + H` or click "Hint" in Waybar
* **Quick Reference**: Available in the application menu under "Help"

---

## 🗺️ Development Roadmap

* [ ] **Progress indicators** for downloads and compilation
* [ ] **Enhanced NVIDIA handling** with automatic fallback
* [ ] **Expanded theme packs** and customization options
* [ ] **Hardware detection improvements**
* [ ] **Rollback and recovery mechanisms**

---

## 🆘 Support & Troubleshooting

### Installer Issues
Open an issue at: [Arch-Hyprlanda Issues](https://github.com/hetfs/Arch-hyprlanda/issues)


### Community Support
* Check existing issues before posting
* Include your hardware specifications
* Provide installation logs when possible

---

## 📜 License & Acknowledgments

This project builds upon the excellent work of:
* [Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots) for configurations
* [Hyprland](https://hyprland.org/) for the window manager
* Arch Linux community for the base system

**Always remember**: With great automation comes great responsibility. Backup before you automate! 💾
