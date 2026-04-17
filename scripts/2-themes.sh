#!/bin/bash

# Themes Installation Script
# Installs:
# - MacTahoe (GTK/Shell theme) - from GitHub
# - Bibata-Modern-Ice (Cursor theme)

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_DIR="$HOME/.local/share/themes"
CURSOR_DIR="$HOME/.local/share/icons"
TMP_DIR="/tmp/ubuntu-setup-themes"

mkdir -p "$THEMES_DIR"
mkdir -p "$CURSOR_DIR"
mkdir -p "$TMP_DIR"

MACTQHOE_REPO="https://github.com/vinceliuice/MacTahoe-gtk-theme.git"
BIBATA_URL="https://www.gnome-look.org/content/get.php?id=1197198"
BIBATA_PAGE_URL="https://www.gnome-look.org/p/1197198"
BIBATA_LOCAL_ARCHIVE="$REPO_DIR/Bibata-Modern-Ice.tar.xz"

GTK_THEME_NAME="MacTahoe-Light-purple"
SHELL_THEME_NAME="MacTahoe-Light-purple"
CURSOR_THEME_NAME="Bibata-Modern-Ice"

echo "Installing Themes..."
echo ""

# Install MacTahoe theme
install_mactahoe() {
    echo "Installing MacTahoe theme..."

    if [ -d "$THEMES_DIR/MacTahoe-Light-purple" ]; then
        echo "  -> MacTahoe-Light-purple already installed, skipping"
    else
        # Check for required dependencies
        install_dependencies() {
            local deps=("sassc" "libglib2.0-dev-bin" "libxml2-utils")
            local missing=()

            for dep in "${deps[@]}"; do
                if ! dpkg -s "$dep" &> /dev/null 2>&1; then
                    missing+=("$dep")
                fi
            done

            if [ ${#missing[@]} -gt 0 ]; then
                echo "  -> Installing dependencies: ${missing[*]}"
                sudo apt-get update
                sudo apt-get install -y "${missing[@]}" 2>/dev/null || \
                sudo apt-get install -y sassc libglib2.0-dev libxml2-utils 2>/dev/null || true
            fi
        }

        install_dependencies

        if command -v git &> /dev/null; then
            echo "  -> Cloning MacTahoe repository..."
            rm -rf "$TMP_DIR/MacTahoe"
            git clone --depth 1 "$MACTQHOE_REPO" "$TMP_DIR/MacTahoe" 2>/dev/null

            if [ -d "$TMP_DIR/MacTahoe" ]; then
                echo "  -> Installing MacTahoe themes..."
                cd "$TMP_DIR/MacTahoe"

                # Install with purple accent and light color
                if ./install.sh -t purple -c light -l 2>/dev/null; then
                    echo "  -> MacTahoe theme installed via installer"
                else
                    # Fallback: copy themes manually
                    echo "  -> Manual install fallback..."
                    mkdir -p "$THEMES_DIR"
                    if [ -d "themes" ]; then
                        cp -r themes/* "$THEMES_DIR/"
                    fi
                    echo "  -> MacTahoe theme copied manually"
                fi
                cd - > /dev/null
            else
                echo "  -> Failed to clone MacTahoe repository"
            fi
        else
            echo "  -> git not installed, cannot download MacTahoe"
            echo "  -> Install git with: sudo apt install git"
        fi
    fi
}

# Install Bibata cursor theme
install_bibata() {
    echo "Installing Bibata cursor theme..."

    if [ -d "$CURSOR_DIR/Bibata-Modern-Ice" ]; then
        echo "  -> Bibata-Modern-Ice already installed, skipping"
    else
        if [ -f "$BIBATA_LOCAL_ARCHIVE" ]; then
            echo "  -> Installing Bibata from local archive: $BIBATA_LOCAL_ARCHIVE"
            tar -xJf "$BIBATA_LOCAL_ARCHIVE" -C "$TMP_DIR/" 2>/dev/null || {
                echo "  -> Local archive extract failed, falling back to download"
                rm -f "$TMP_DIR/Bibata.tar.gz"
            }
        fi

        if [ ! -d "$TMP_DIR/Bibata-Modern-Ice" ]; then
            echo "  -> Downloading Bibata cursor theme..."
            wget -q --show-progress -O "$TMP_DIR/Bibata.tar.gz" "$BIBATA_URL" 2>/dev/null || {
                echo "  -> Failed to download Bibata from gnome-look.org"
                echo "  -> Try manual download from: $BIBATA_PAGE_URL"
                return
            }

            echo "  -> Extracting..."
            tar -xzf "$TMP_DIR/Bibata.tar.gz" -C "$TMP_DIR/" 2>/dev/null || {
                # Try unpacking xz or zip if needed
                tar -xJf "$TMP_DIR/Bibata.tar.gz" -C "$TMP_DIR/" 2>/dev/null || \
                unzip -q -o "$TMP_DIR/Bibata.tar.gz" -d "$TMP_DIR/" 2>/dev/null || true
            }
        fi

        # Find and install the cursor theme
        if [ -d "$TMP_DIR/Bibata-Modern-Ice" ]; then
            cp -r "$TMP_DIR/Bibata-Modern-Ice" "$CURSOR_DIR/"
            echo "  -> Bibata cursor theme installed"
        elif [ -d "$TMP_DIR"/Bibata* ]; then
            cp -r "$TMP_DIR"/Bibata* "$CURSOR_DIR/"
            echo "  -> Bibata cursor theme installed"
        else
            echo "  -> Could not find Bibata cursor theme in archive"
            ls -la "$TMP_DIR/" 2>/dev/null || true
        fi
    fi
}

install_mactahoe
echo ""
install_bibata

# Apply themes via dconf
echo ""
echo "Applying themes via dconf..."

if command -v dconf &> /dev/null; then
    # Set GTK theme
    dconf write /org/gnome/desktop/interface/gtk-theme "'$GTK_THEME_NAME'" 2>/dev/null && \
    echo "  -> GTK theme set to '$GTK_THEME_NAME'" || \
    echo "  -> Failed to set GTK theme"

    # Set icon theme
    dconf write /org/gnome/desktop/interface/icon-theme "'Gruvbox-Plus-Light'" 2>/dev/null && \
    echo "  -> Icon theme set to 'Gruvbox-Plus-Light'" || \
    echo "  -> Failed to set icon theme"

    # Set cursor theme
    dconf write /org/gnome/desktop/interface/cursor-theme "'$CURSOR_THEME_NAME'" 2>/dev/null && \
    echo "  -> Cursor theme set to '$CURSOR_THEME_NAME'" || \
    echo "  -> Failed to set cursor theme"

else
    echo "  -> dconf not available, skipping theme application"
fi

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "Themes installation complete!"
echo ""
echo "Installed themes:"
ls -la "$THEMES_DIR/" 2>/dev/null || echo "  (No themes found in $THEMES_DIR)"
echo ""
echo "Installed cursor themes:"
ls -la "$CURSOR_DIR/" 2>/dev/null || echo "  (No cursors found in $CURSOR_DIR)"
echo ""
echo "Note: You may need to log out and log back in or restart GNOME Shell for all changes to take effect."
echo "To restart GNOME Shell, press: Alt+F2, then type 'r', then Enter"
