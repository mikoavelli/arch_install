#!/usr/bin/env bash

read -p "Enter your email for git config and ssh-key: " email
read -p "Enter your name for git config: " name

# org.gnome.desktop.background
gsettings set org.gnome.desktop.background picture-uri 'file:///home/miko/.config/background'
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///home/miko/.config/background'

# org.gnome.break-reminders.eyesight
gsettings set org.gnome.desktop.break-reminders.movement play-sound false
gsettings set org.gnome.desktop.break-reminders.movement notify-upcoming false
gsettings set org.gnome.desktop.break-reminders.eyesight play-sound false

# org.gnome.desktop.input-sources
gsettings set org.gnome.desktop.input-sources xkb-options "['grp:caps_toggle']"

# org.gnome.desktop.interface
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.interface icon-theme "MoreWaita"
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"
gsettings set org.gnome.desktop.interface font-name 'Inter 12'
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
gsettings set org.gnome.desktop.interface document-font-name 'Inter 12'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 12'
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface enable-hot-corners false
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# org.gnome.desktop.media-handling
gsettings set org.gnome.desktop.media-handling autorun-x-content-start-app "['x-content/ostree-repository']"

# org.gnome.desktop.notifications
gsetting set org.gnome.desktop.notifications show-in-lock-screen false

# org.gnome.desktop.peripherals
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false
gsettings set org.gnome.desktop.peripherals.touchpad speed 0.2
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 15
gsettings set org.gnome.desktop.peripherals.keyboard delay 200
gsettings set org.gnome.desktop.peripherals.mouse speed 0.3
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'

# org.gnome.desktop.privacy
gsettings set org.gnome.desktop.privacy remember-recent-files false
gsettings set org.gnome.desktop.privacy disable-camera true
gsettings set org.gnome.desktop.search-providers disabled "['org.gnome.Calculator.desktop', 'firefox.desktop', 'org.gnome.Terminal.desktop']"

# org.gnome.desktop.session
gsettings set org.gnome.desktop.session idle-delay 600

# org.gnome.desktop.screen-time-limits
gsettings set org.gnome.desktop.screen-time-limits history-enabled false
gsettings set org.gnome.desktop.screen-time-limits grayscale false

# org.gnomve.desktop.sound
gsettings set org.gnome.desktop.sound event-sounds false
gsettings set org.gnome.desktop.sound theme-name '__custom'
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

# org.gnome.desktop.wm.preferences
# keybinding are configuring with keybindings.sh
gsetting set org.gnome.desktop.wm.preferences resize-with-right-button true

echo "-> Creating ssh-key for github"
ssh-keygen -t ed25519 -C "$email" -f $HOME/.ssh/github -N ""

echo "-> Configure specific flatpaks"
sudo flatpak override --env=QT_SCALE_FACTOR=1.2 org.kde.okular

echo "-> Base git configuration"
git config --global user.email "$email"
git config --global user.name "$name"
git config --global core.editor "nvim"

echo "-> Installing external application for Firefox extension 'Video DownloadHelper'"
curl -sSLf https://github.com/aclap-dev/vdhcoapp/releases/latest/download/install.sh | bash

echo "-> Hiding bloat desktop entries"
sudo mv /usr/share/applications/qv4l2.desktop{,.bak}
sudo mv /usr/share/applications/bssh.desktop{,.bak}
sudo mv /usr/share/applications/bvnc.desktop{,.bak}
sudo mv /usr/share/applications/avahi-discover.desktop{,.bak}
sudo mv /usr/share/applications/qvidcap.desktop{,.bak}
sudo mv /usr/share/applications/google-maps-geo-handler.desktop{,.bak}
sudo mv /usr/share/applications/wheelmap-geo-handler.desktop{,.bak}
sudo mv /usr/share/applications/org.gnome.OnlineAccounts.OAuth2.desktop{,.bak}
sudo mv /usr/share/applications/ktelnetservice6.desktop{,.bak}
sudo mv /usr/share/applications/gcm-import.desktop{,.bak}

echo "-> Directories tweaks"
rm -r ~/Templates ~/Public
mkdir ~/Projects

echo "-> Enabling gnome-extensions ..."
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gnome-extensions enable dash-to-panel@jderose9.github.com
gnome-extensions enable just-perfection-desktop@just-perfection

echo "-> Install Catppuccin theme for gnome-terminal"
curl -L https://raw.githubusercontent.com/catppuccin/gnome-terminal/v1.0.0/install.py | python3 -

echo "-> Restoring shortcuts"
bash "./$(dirname $0)/keybindings/keybindings.sh" restore

echo "-> Copy .desktop to ~/.local/share/applications/"
cp -R "$(dirname $0)/applications" ~/.local/share/
