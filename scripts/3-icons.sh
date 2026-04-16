#!/bin/bash

# Icons Installation Script
# Installs:
# - Gruvbox Plus Icon Pack - from gnome-look.org

set -e

ICONS_DIR="$HOME/.icons"
TMP_DIR="/tmp/ubuntu-setup-icons"

mkdir -p "$ICONS_DIR"
mkdir -p "$TMP_DIR"

GRUVBOX_ICONS_URL="https://www.gnome-look.org/content/get.php?id=1961046"

echo "Installing Icon Themes..."
echo ""

install_gruvbox_icons() {
    echo "Installing Gruvbox Plus icons..."

    if [ -d "$ICONS_DIR/Gruvbox-Plus-Light" ]; then
        echo "  -> Gruvbox-Plus-Light already installed, skipping"
        return
    fi

    echo "  -> Downloading Gruvbox Plus icons..."
    wget -q --show-progress -O "$TMP_DIR/GruvboxIcons.tar.gz" "$GRUVBOX_ICONS_URL" 2>/dev/null || {
        echo "  -> Failed to download from gnome-look.org"
        echo "  -> Try manual download from: https://www.gnome-look.org/p/1961046"
        return
    }

    echo "  -> Extracting..."
    mkdir -p "$TMP_DIR/GruvboxExtract"

    # Try different extraction methods
    tar -xzf "$TMP_DIR/GruvboxIcons.tar.gz" -C "$TMP_DIR/GruvboxExtract" 2>/dev/null || \
    unzip -q -o "$TMP_DIR/GruvboxIcons.tar.gz" -d "$TMP_DIR/GruvboxExtract" 2>/dev/null || \
    tar -xzf "$TMP_DIR/GruvboxIcons.tar.gz" 2>/dev/null

    # Find the icon theme folder
    if [ -d "$TMP_DIR/GruvboxExtract/Gruvbox-Plus-Light" ]; then
        cp -r "$TMP_DIR/GruvboxExtract/Gruvbox-Plus-Light" "$ICONS_DIR/"
        echo "  -> Gruvbox-Plus-Light installed"
    elif [ -d "$TMP_DIR/GruvboxExtract"/Gruvbox* ]; then
        cp -r "$TMP_DIR/GruvboxExtract"/Gruvbox* "$ICONS_DIR/"
        echo "  -> Gruvbox icons installed"
    elif [ -d "$TMP_DIR/Gruvbox-Plus-Light" ]; then
        cp -r "$TMP_DIR/Gruvbox-Plus-Light" "$ICONS_DIR/"
        echo "  -> Gruvbox-Plus-Light installed"
    else
        # Search recursively for any .icons directory or index.theme
        find "$TMP_DIR" -name "index.theme" 2>/dev/null | head -5 | while read theme_file; do
            icon_dir=$(dirname "$theme_file")
            cp -r "$icon_dir" "$ICONS_DIR/"
            echo "  -> Installed: $(basename "$icon_dir")"
        done
    fi
}

install_gruvbox_icons

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "Icons installation complete!"
echo ""
echo "To apply icon theme, use GNOME Tweaks or run:"
echo "  dconf write /org/gnome/desktop/interface/icon-theme \"'Gruvbox-Plus-Light'\""
