#!/usr/bin/env bash

CONFIG_DIR="$(dirname $0)"

do_backup() {
  echo "Creating keyboard bindings backup..."

  mkdir -p "$CONFIG_DIR"

  dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > "$CONFIG_DIR/media-keys.conf"
  dconf dump /org/gnome/mutter/keybindings/ > "$CONFIG_DIR/mutter-keybindings.conf"
  dconf dump /org/gnome/shell/keybindings/ > "$CONFIG_DIR/shell-keybindings.conf"
  dconf dump /org/gnome/mutter/wayland/keybindings/ > "$CONFIG_DIR/wayland-keybindings.conf"
  dconf dump /org/gnome/desktop/wm/keybindings/ > "$CONFIG_DIR/wm-keybindings.conf"

  echo "Backup is stored in '$CONFIG_DIR' directory."
}

do_restore() {
  echo "Restoring keyboard bindings from '$CONFIG_DIR' directory..."

  if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: Directory '$CONFIG_DIR' doen't exists."
    exit 1
  fi

  dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$CONFIG_DIR/media-keys.conf"
  dconf load /org/gnome/mutter/keybindings/ < "$CONFIG_DIR/mutter-keybindings.conf"
  dconf load /org/gnome/shell/keybindings/ < "$CONFIG_DIR/shell-keybindings.conf"
  dconf load /org/gnome/mutter/wayland/keybindings/ < "$CONFIG_DIR/wayland-keybindings.conf"
  dconf load /org/gnome/desktop/wm/keybindings/ < "$CONFIG_DIR/wm-keybindings.conf"

  echo "Keyboard binding has been restored."
}

case "$1" in
  backup)
    do_backup
    ;;
  restore)
    do_restore
    ;;
  *)
    echo "script usage: $(basename $0) {backup|restore}"
    exit 1
    ;;
esac

exit 0
