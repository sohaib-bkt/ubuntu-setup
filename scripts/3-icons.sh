#!/bin/bash

# Icons Installation Script
# Installs:
# - Gruvbox Plus Icon Pack - from gnome-look.org

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICONS_DIR="$HOME/.local/share/icons"
TMP_DIR="/tmp/ubuntu-setup-icons"
ICON_THEME_NAME="Gruvbox-Plus-Light"

mkdir -p "$ICONS_DIR"
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
    else
        if [ -f "$GRUVBOX_LOCAL_ARCHIVE" ]; then
            echo "  -> Installing Gruvbox from local archive: $GRUVBOX_LOCAL_ARCHIVE"
            rm -rf "$TMP_DIR/GruvboxExtract"
            mkdir -p "$TMP_DIR/GruvboxExtract"

            # Try different extraction methods
            if ! tar -xzf "$GRUVBOX_LOCAL_ARCHIVE" -C "$TMP_DIR/GruvboxExtract" 2>/dev/null; then
                echo "  -> Local archive extract failed, trying download..."
            fi
        fi

        if [ -z "$(ls -A "$TMP_DIR/GruvboxExtract" 2>/dev/null)" ]; then
            echo "  -> Downloading Gruvbox Plus icons..."
            rm -f "$TMP_DIR/GruvboxIcons.tar.gz"
            wget -q --show-progress -O "$TMP_DIR/GruvboxIcons.tar.gz" "$GRUVBOX_ICONS_URL" 2>/dev/null || {
                echo "  -> Failed to download from gnome-look.org"
                echo "  -> Try manual download from: $GRUVBOX_PAGE_URL"
                return
            }

            echo "  -> Extracting..."
            rm -rf "$TMP_DIR/GruvboxExtract"
            mkdir -p "$TMP_DIR/GruvboxExtract"

            # Try different extraction methods
            tar -xzf "$TMP_DIR/GruvboxIcons.tar.gz" -C "$TMP_DIR/GruvboxExtract" 2>/dev/null || \
            unzip -q -o "$TMP_DIR/GruvboxIcons.tar.gz" -d "$TMP_DIR/GruvboxExtract" 2>/dev/null || \
            tar -xzf "$TMP_DIR/GruvboxIcons.tar.gz" 2>/dev/null
        fi

        # Find the icon theme folder
        local found=false
        if [ -d "$TMP_DIR/GruvboxExtract/Gruvbox-Plus-Light" ]; then
            cp -r "$TMP_DIR/GruvboxExtract/Gruvbox-Plus-Light" "$ICONS_DIR/"
            echo "  -> Gruvbox-Plus-Light installed"
            found=true
        elif [ -d "$TMP_DIR/GruvboxExtract"/Gruvbox* ]; then
            for dir in "$TMP_DIR/GruvboxExtract"/Gruvbox*; do
                if [ -d "$dir" ]; then
                    cp -r "$dir" "$ICONS_DIR/"
                    echo "  -> Installed: $(basename "$dir")"
                    found=true
                fi
            done
        elif [ -d "$TMP_DIR/Gruvbox-Plus-Light" ]; then
            cp -r "$TMP_DIR/Gruvbox-Plus-Light" "$ICONS_DIR/"
            echo "  -> Gruvbox-Plus-Light installed"
            found=true
        fi

        if [ "$found" = false ]; then
            # Search recursively for any .icons directory or index.theme
            while IFS= read -r theme_file; do
                icon_dir=$(dirname "$theme_file")
                cp -r "$icon_dir" "$ICONS_DIR/"
                echo "  -> Installed: $(basename "$icon_dir")"
            done < <(find "$TMP_DIR" -maxdepth 5 -name "index.theme" 2>/dev/null | head -5)

            # Also check for icon directories without index.theme
            while IFS= read -r icon_dir; do
                if [ -f "$icon_dir/index.theme" ]; then
                    cp -r "$icon_dir" "$ICONS_DIR/"
                    echo "  -> Installed: $(basename "$icon_dir")"
                fi
            done < <(find "$TMP_DIR" -maxdepth 4 -type d -name "icons" 2>/dev/null)
        fi
    fi
}

install_gruvbox_icons

# Apply icon theme via dconf
echo ""
echo "Applying icon theme via dconf..."

if command -v dconf &> /dev/null; then
    dconf write /org/gnome/desktop/interface/icon-theme "'$ICON_THEME_NAME'" 2>/dev/null && \
    echo "  -> Icon theme set to '$ICON_THEME_NAME'" || \
    echo "  -> Failed to set icon theme (theme may not be properly installed)"
else
    echo "  -> dconf not available, skipping icon theme application"
fi

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "Icons installation complete!"
echo ""
echo "Installed icon themes:"
ls -la "$ICONS_DIR/" 2>/dev/null || echo "  (No icon themes found in $ICONS_DIR)"
echo ""
echo "Note: You may need to log out and log back in or restart GNOME Shell for changes to take effect."
