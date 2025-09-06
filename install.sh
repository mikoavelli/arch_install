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
  firefox
  fwupd
  git
  gst-plugins-bad
  gst-plugins-base
  gst-plugins-ugly
  lazygit
  less
  man
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  ntfs-3g
  okular
  power-profiles-daemon
  pwgen
  resources
  sbctl
  steam
  telegram-desktop
  tree
  ufw
  vlc
  vlc-plugins-all
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
  gnome-shell-extension-just-perfection-desktop
  morewaita-icon-theme
  spicetify-cli
  spotify
  visual-studio-code-bin
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

echo "-> Cloning LazyVim starter"
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/LazyVim/starter ~/.config/nvim
else
  echo "--> Some nvim config already exists"
fi

echo "-> Installing 'ideapad' gnome extension"
mkdir -p "$HOME/.local/share/gnome-shell/extensions/"
if [ ! -d "$HOME/.local/share/gnome-shell/extensions/ideapad@laurento.frittella" ]; then
  git clone https://github.com/laurento/gnome-shell-extension-ideapad.git "$HOME/.local/share/gnome-shell/extensions/ideapad@laurento.frittella"
else
  echo "--> 'ideapad extension already installed'"
fi

echo "-> Additional required setup for 'ideapad' extension"
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/bus/platform/drivers/ideapad_acpi/VPC????\:??/conservation_mode" | sudo tee /etc/sudoers.d/ideapad
if ! grep -q "ideapad_laptop" /etc/modules; then
  echo "ideapad_laptop" | sudo tee -a /etc/modules
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

echo "-> Finalization ..."
yay -Yc --noconfirm

echo "-> Secure Boot setup with sbctl"
sudo sbctl create-keys
sudo sbctl sign /boot/vmlinuz-linux
sudo sbctl sign /boot/EFI/systemd/systemd-bootx64.efi
sudo sbctl sign /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl verify
sudo sbctl enroll-keys

echo "--- Setup Complete! Please reboot your system. ---"
