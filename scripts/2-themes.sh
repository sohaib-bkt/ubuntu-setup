#!/bin/bash

# Themes Installation Script
# Installs:
# - MacTahoe-Light-purple (GTK/Shell theme)
# - Bibata-Modern-Ice (Cursor theme)

set -e

THEMES_DIR="$HOME/.themes"
CURSOR_DIR="$HOME/.icons"

mkdir -p "$THEMES_DIR"
mkdir -p "$CURSOR_DIR"

install_theme() {
    local name="$1"
    local source_dir="$2"
    local dest_dir="$3"
    local theme_type="$4"

    echo "Installing $theme_type theme: $name"

    if [ -d "$dest_dir/$name" ]; then
        echo "  -> $name already installed, skipping"
        return
    fi

    if [ -d "$source_dir/$name" ]; then
        cp -r "$source_dir/$name" "$dest_dir/"
        echo "  -> Copied from local source: $source_dir/$name"
    else
        echo "  -> Theme not found in source directory"
        echo "  -> Please add the theme to: $source_dir/$name"
    fi
}

echo "Installing Themes..."
echo ""

# Check for local theme sources
LOCAL_THEMES_DIR="$HOME/.themes"
LOCAL_ICONS_DIR="$HOME/.icons"

# MacTahoe-Light-purple (GTK/Shell)
install_theme "MacTahoe-Light-purple" "$LOCAL_THEMES_DIR" "$THEMES_DIR" "GTK/Shell"

# Check for other MacTahoe variants
for variant in Dark Dark-blue Dark-green Dark-grey Dark-orange Dark-pink; do
    if [ -d "$LOCAL_THEMES_DIR/MacTahoe-$variant" ]; then
        install_theme "MacTahoe-$variant" "$LOCAL_THEMES_DIR" "$THEMES_DIR" "GTK/Shell"
    fi
done

# Everforest themes
for variant in "" -MB-Light -MB-Light-hdpi -MB-Light-xhdpi; do
    if [ -d "$LOCAL_THEMES_DIR/Everforest$variant" ]; then
        install_theme "Everforest$variant" "$LOCAL_THEMES_DIR" "$THEMES_DIR" "GTK/Shell"
    fi
done

# Gruvbox themes
for variant in -Plus-Dark -Plus-Light; do
    if [ -d "$LOCAL_THEMES_DIR/Gruvbox$variant" ]; then
        install_theme "Gruvbox$variant" "$LOCAL_THEMES_DIR" "$THEMES_DIR" "GTK/Shell"
    fi
done

# Bibata cursor theme
install_theme "Bibata-Modern-Ice" "$LOCAL_ICONS_DIR" "$CURSOR_DIR" "Cursor"

echo ""
echo "Themes installation complete!"
echo ""
echo "To apply themes, use GNOME Tweaks or run:"
echo "  dconf write /org/gnome/desktop/interface/gtk-theme \"'MacTahoe-Light-purple'\""
echo "  dconf write /org/gnome/shell/extensions/user-theme/name \"'MacTahoe-Light-purple'\""
echo "  dconf write /org/gnome/desktop/interface/cursor-theme \"'Bibata-Modern-Ice'\""
