#!/usr/bin/env bash

set -e

GNOME_PACKAGES=(
  adw-gtk-theme
  gdm
  gnome-calculator
  gnome-control-center
  gnome-disk-utility
  gnome-keyring
  gnome-power-manager
  gnome-settings-daemon
  gnome-shell
  gnome-shell-extension-appindicator
  gnome-shell-extension-dash-to-panel
  gnome-terminal
  gnome-tweaks
  gvfs
  gvfs-mtp
  loupe
  nautilus
  xdg-user-dirs-gtk
)

AMD_VIDEO_DRIVERS=(
  libva-mesa-driver
  libva-utils
  lib32-mesa
  lib32-vulkan-mesa-layers
  lib32-vulkan-radeon
  mesa
  vulkan-mesa-layers
  vulkan-radeon
)

ESSENTIAL_PACKAGES=(
  base-devel
  bash-completion
  bat
  dosfstools
  ffmpegthumbnailer
  firefox
  flatpak
  fwupd
  git
  gst-plugins-bad
  gst-plugins-base
  gst-plugins-ugly
  inter-font
  lazygit
  less
  man
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  ntfs-3g
  power-profiles-daemon
  pwgen
  reflector
  resources
  sbctl
  steam
  telegram-desktop
  tree
  ttf-jetbrains-mono-nerd
  ufw
  vlc
  vlc-plugin-ffmpeg
  vlc-plugin-freetype
  vlc-plugin-x264
  wl-clipboard
)

LAZYVIM_DEPS=(
  curl
  fd
  fzf
  gcc
  luarocks
  make
  neovim
  ripgrep
  unzip
)

AUR_PACKAGES=(
  gdm-settings
  gnome-shell-extension-just-perfection-desktop-git
  morewaita-icon-theme
)

FLATPAK_PACKAGES=(
  org.kde.okular
)

echo "-> Starting Arch Linux Setup"

echo "-> Synchronizing package databases and updating system"
sudo pacman -Syu --noconfirm

echo "-> Changing default ttl for free mobile hotspot"
sudo mkdir -p /etc/sysctl.d/
echo "net.ipv4.ip_default_ttl = 65" | sudo tee /etc/sysctl.d/99-ttl-mobile-hotspot.conf

echo "-> Hiding systemd-boot menu"
echo "timeout 0" | sudo tee /boot/loader/loader.conf

echo "-> Disabling motherboard speaker beep"
echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf

echo "-> Creating SSH config for custom key names"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
if ! grep -q "Host github.com" ~/.ssh/config; then
  cat <<EOT | tee -a ~/.ssh/config
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github
EOT
fi

echo "-> Installing packages"
sudo pacman -S --needed --noconfirm \
  "${GNOME_PACKAGES[@]}" \
  "${AMD_VIDEO_DRIVERS[@]}" \
  "${ESSENTIAL_PACKAGES[@]}" \
  "${LAZYVIM_DEPS[@]}"

sudo flatpak install flathub -y \
  "${FLATPAK_PACKAGES}"

echo "-> Filter best Romania https mirrors with reflector"
sudo reflector --country Romania --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo "-> Cloning LazyVim starter"
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/LazyVim/starter ~/.config/nvim
else
  echo "--> Some nvim config already exists"
fi

if ! command -v yay &>/dev/null; then
  echo "-> Installing yay"
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd -
  rm -rf yay
  cd
else
  echo "--> yay is already installed"
fi

echo "-> Installing yay packages"
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

echo "-> Making basic ufw changes"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

echo "-> Enabling necessary services"
sudo systemctl enable gdm.service
sudo systemctl enable bluetooth.service
sudo systemctl enable power-profiles-daemon.service
sudo systemctl enable ufw.service

echo "-> Disabling some services .."
sudo systemctl disable remote-fs.target avahi-daemon.service
sudo systemctl mask remote-fs.target avahi-daemon.service

echo "-> Temporary fix for changing keyboard layout on CapsLock (downgrading 'mutter' to 49.0.5)"
sudo pacman -U --needed --noconfirm https://archive.archlinux.org/packages/m/mutter/mutter-49.0-5-x86_64.pkg.tar.zst

echo "--> Add 'mutter' package to IgnorePkg"
sudo sed -i '/^#IgnorePkg/ s/^#//' /etc/pacman.conf
set +H
sudo sed -i "/^IgnorePkg/!b; /mutter/b; s/$/ mutter/" /etc/pacman.conf
set -H

echo "-> Finalization ..."
sudo pacman -Sc --noconfirm
yay -Yc --noconfirm

echo "-> Secure Boot setup with sbctl"
sudo sbctl create-keys
sudo sbctl sign /boot/vmlinuz-linux
sudo sbctl sign /boot/EFI/systemd/systemd-bootx64.efi
sudo sbctl sign /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl verify
sudo sbctl enroll-keys

echo "--- Setup Complete! Please reboot your system. ---"
