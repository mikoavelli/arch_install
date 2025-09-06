#!/usr/bin/env bash

# Spicetify custom configuration script.
# Official documentation:
# https://spicetify.app/docs/advanced-usage/installation

set -e

yay -S --needed --noconfirm spicetify-cli

# This script should be executed only after logging into spotify app.

if [ ! -f "$HOME/.config/spotify/prefs" ]; then
  echo "prefs file has not been generated, please log into spotify account"
  exit 0
fi

# Before applying Spicetify, you need to gain write permission on Spotify files
sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

# Run with no command once to generate config file
spicetify

# Executed to fix problem at app startup
spicetify config sidebar_config 0

# Provides 'Experimental features' and other
spicetify backup apply enable-devtools

# Cloning spicetify community themes
git clone --depth=1 https://github.com/spicetify/spicetify-themes.git

# Installing only 'text' themes (I don't like the others)
cp -r spicetify-themes/text/ ~/.config/spicetify/Themes/
rm -rf spicetify-themes

# Applying Catppuccin-Mocha theme (purple accent color is kinda cool)
spicetify config current_theme text
spicetify config color_scheme CatppuccinMocha

# Applying all changes
spicetify apply
