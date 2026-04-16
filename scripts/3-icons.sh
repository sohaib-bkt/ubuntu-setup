#!/bin/bash

# Icons Installation Script
# Installs:
# - Gruvbox Plus Icon Pack - from gnome-look.org

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICONS_DIR="$HOME/.icons"
ICONS_DIR_LOCAL="$HOME/.local/share/icons"
TMP_DIR="/tmp/ubuntu-setup-icons"

mkdir -p "$ICONS_DIR"
mkdir -p "$ICONS_DIR_LOCAL"
mkdir -p "$TMP_DIR"

GRUVBOX_ICONS_URL="https://www.gnome-look.org/content/get.php?id=1961046"
GRUVBOX_PAGE_URL="https://www.gnome-look.org/p/1961046"
GRUVBOX_LOCAL_ARCHIVE="$REPO_DIR/gruvbox-plus-icon-pack.6.3.0.tar.gz"

echo "Installing Icon Themes..."
echo ""

install_gruvbox_icons() {
    echo "Installing Gruvbox Plus icons..."

    if [ -d "$ICONS_DIR/Gruvbox-Plus-Light" ]; then
        echo "  -> Gruvbox-Plus-Light already installed, skipping"
        return
    fi

    if [ -f "$GRUVBOX_LOCAL_ARCHIVE" ]; then
        echo "  -> Installing Gruvbox from local archive: $GRUVBOX_LOCAL_ARCHIVE"
        mkdir -p "$TMP_DIR/GruvboxExtract"
        tar -xzf "$GRUVBOX_LOCAL_ARCHIVE" -C "$TMP_DIR/GruvboxExtract" 2>/dev/null || {
            echo "  -> Local archive extract failed, falling back to download"
            rm -f "$TMP_DIR/GruvboxIcons.tar.gz"
        }
    fi

    if [ -z "$(ls -A "$TMP_DIR/GruvboxExtract" 2>/dev/null)" ]; then
        echo "  -> Downloading Gruvbox Plus icons..."
        wget -q --show-progress -O "$TMP_DIR/GruvboxIcons.tar.gz" "$GRUVBOX_ICONS_URL" 2>/dev/null || {
            echo "  -> Failed to download from gnome-look.org"
            echo "  -> Try manual download from: $GRUVBOX_PAGE_URL"
            return
        }

        echo "  -> Extracting..."
        mkdir -p "$TMP_DIR/GruvboxExtract"

        # Try different extraction methods
        tar -xzf "$TMP_DIR/GruvboxIcons.tar.gz" -C "$TMP_DIR/GruvboxExtract" 2>/dev/null || \
        unzip -q -o "$TMP_DIR/GruvboxIcons.tar.gz" -d "$TMP_DIR/GruvboxExtract" 2>/dev/null || \
        tar -xzf "$TMP_DIR/GruvboxIcons.tar.gz" 2>/dev/null
    fi

    # Find the icon theme folder
    if [ -d "$TMP_DIR/GruvboxExtract/Gruvbox-Plus-Light" ]; then
        cp -r "$TMP_DIR/GruvboxExtract/Gruvbox-Plus-Light" "$ICONS_DIR/"
        cp -r "$TMP_DIR/GruvboxExtract/Gruvbox-Plus-Light" "$ICONS_DIR_LOCAL/"
        echo "  -> Gruvbox-Plus-Light installed"
    elif [ -d "$TMP_DIR/GruvboxExtract"/Gruvbox* ]; then
        cp -r "$TMP_DIR/GruvboxExtract"/Gruvbox* "$ICONS_DIR/"
        cp -r "$TMP_DIR/GruvboxExtract"/Gruvbox* "$ICONS_DIR_LOCAL/"
        echo "  -> Gruvbox icons installed"
    elif [ -d "$TMP_DIR/Gruvbox-Plus-Light" ]; then
        cp -r "$TMP_DIR/Gruvbox-Plus-Light" "$ICONS_DIR/"
        cp -r "$TMP_DIR/Gruvbox-Plus-Light" "$ICONS_DIR_LOCAL/"
        echo "  -> Gruvbox-Plus-Light installed"
    else
        # Search recursively for any .icons directory or index.theme
        find "$TMP_DIR" -name "index.theme" 2>/dev/null | head -5 | while read theme_file; do
            icon_dir=$(dirname "$theme_file")
            cp -r "$icon_dir" "$ICONS_DIR/"
            cp -r "$icon_dir" "$ICONS_DIR_LOCAL/"
            echo "  -> Installed: $(basename "$icon_dir")"
        done
    fi
}

install_gruvbox_icons

if command -v dconf &> /dev/null; then
    dconf write /org/gnome/desktop/interface/icon-theme "'Gruvbox-Plus-Light'" || true
    echo "  -> Icon theme set to Gruvbox-Plus-Light"
fi

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "Icons installation complete!"
echo ""
echo "To apply icon theme, use GNOME Tweaks or run:"
echo "  dconf write /org/gnome/desktop/interface/icon-theme \"'Gruvbox-Plus-Light'\""
