#!/usr/bin/env bash

read -p "Enter your email for git config and ssh-key: " email
read -p "Enter your name for git config: " name

echo "-> Enable 125% scaling (Large Text option in Accessibility)"
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25

echo "-> Applying themes"
gsettings set org.gnome.desktop.interface icon-theme "MoreWaita"
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"

echo "-> Creating ssh-key for github"
echo "-> Path to save ssh-key: $HOME/.ssh/github"
ssh-keygen -t ed25519 -C "$email"

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

echo "-> Remove bloat okular desktop entries"
sudo rm /usr/share/applications/okularApplication_comicbook.desktop
sudo rm /usr/share/applications/okularApplication_djvu.desktop
sudo rm /usr/share/applications/okularApplication_dvi.desktop
sudo rm /usr/share/applications/okularApplication_epub.desktop
sudo rm /usr/share/applications/okularApplication_fax.desktop
sudo rm /usr/share/applications/okularApplication_fb.desktop
sudo rm /usr/share/applications/okularApplication_ghostview.desktop
sudo rm /usr/share/applications/okularApplication_kimgio.desktop
sudo rm /usr/share/applications/okularApplication_md.desktop
sudo rm /usr/share/applications/okularApplication_mobi.desktop
sudo rm /usr/share/applications/okularApplication_pdf.desktop
sudo rm /usr/share/applications/okularApplication_tiff.desktop
sudo rm /usr/share/applications/okularApplication_txt.desktop
sudo rm /usr/share/applications/okularApplication_xps.desktop

echo "-> Directories tweaks"
rm -r ~/Templates ~/Public
mkdir ~/Projects

echo "-> Enabling gnome-extensions ..."
gnome-extensions enable ideapad@laurento.frittella
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gnome-extensions enable dash-to-panel@jderose9.github.com
gnome-extensions enable just-perfection-desktop@just-perfection

echo "-> Restoring shortcuts"
bash "./$(dirname $0)/keybindings/keybindings.sh" restore

echo "-> Copy .desktop to ~/.local/share/applications/"
cp -R "$(dirname $0)/applications" ~/.local/share/

echo "-> Copy fonts to ~/local/share/fonts"
cp -R "$(dirname $0)/fonts" ~/.local/share/
