#!/bin/bash

# Icons Installation Script
# Installs:
# - Gruvbox-Plus-Light (Icon theme)

set -e

ICONS_DIR="$HOME/.icons"

mkdir -p "$ICONS_DIR"

install_icon_theme() {
    local name="$1"
    local source_dir="$2"

    echo "Installing icon theme: $name"

    if [ -d "$ICONS_DIR/$name" ]; then
        echo "  -> $name already installed, skipping"
        return
    fi

    if [ -d "$source_dir/$name" ]; then
        cp -r "$source_dir/$name" "$ICONS_DIR/"
        echo "  -> Copied from local source: $source_dir/$name"
    else
        echo "  -> Icon theme not found in source directory"
        echo "  -> Please add the theme to: $source_dir/$name"
    fi
}

echo "Installing Icon Themes..."
echo ""

LOCAL_ICONS_DIR="$HOME/.icons"

# Gruvbox-Plus-Light
install_icon_theme "Gruvbox-Plus-Light" "$LOCAL_ICONS_DIR"

# Check for other icon themes in local directory
if [ -d "$LOCAL_ICONS_DIR" ]; then
    for theme in "$LOCAL_ICONS_DIR"/*/; do
        theme_name=$(basename "$theme")
        if [ "$theme_name" != "Gruvbox-Plus-Light" ]; then
            install_icon_theme "$theme_name" "$LOCAL_ICONS_DIR"
        fi
    done
fi

echo ""
echo "Icons installation complete!"
echo ""
echo "To apply icon theme, use GNOME Tweaks or run:"
echo "  dconf write /org/gnome/desktop/interface/icon-theme \"'Gruvbox-Plus-Light'\""
