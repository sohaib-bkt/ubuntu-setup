#!/bin/bash

# Themes Installation Script
# Installs:
# - MacTahoe (GTK/Shell theme) - from GitHub
# - Bibata-Modern-Ice (Cursor theme)

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_DIR="$HOME/.themes"
CURSOR_DIR="$HOME/.icons"
CURSOR_DIR_LOCAL="$HOME/.local/share/icons"
TMP_DIR="/tmp/ubuntu-setup-themes"

mkdir -p "$THEMES_DIR"
mkdir -p "$CURSOR_DIR"
mkdir -p "$CURSOR_DIR_LOCAL"
mkdir -p "$TMP_DIR"

MACTQHOE_REPO="https://github.com/vinceliuice/MacTahoe-gtk-theme.git"
BIBATA_URL="https://www.gnome-look.org/content/get.php?id=1197198"
BIBATA_PAGE_URL="https://www.gnome-look.org/p/1197198"
BIBATA_LOCAL_ARCHIVE="$REPO_DIR/Bibata-Modern-Ice.tar.xz"

echo "Installing Themes..."
echo ""

# Install MacTahoe theme
install_mactahoe() {
    echo "Installing MacTahoe theme..."

    if [ -d "$THEMES_DIR/MacTahoe-Light-purple" ]; then
        echo "  -> MacTahoe-Light-purple already installed, skipping"
        return
    fi

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
            ./install.sh -t purple -c light -l 2>/dev/null || {
                # Fallback: copy themes manually
                mkdir -p "$THEMES_DIR"
                cp -r "$TMP_DIR/MacTahoe/themes/"* "$THEMES_DIR/"
            }
            echo "  -> MacTahoe theme installed"
            cd - > /dev/null
        else
            echo "  -> Failed to clone MacTahoe repository"
        fi
    else
        echo "  -> git not installed, cannot download MacTahoe"
        echo "  -> Install git with: sudo apt install git"
    fi
}

# Install Bibata cursor theme
install_bibata() {
    echo "Installing Bibata cursor theme..."

    if [ -d "$CURSOR_DIR/Bibata-Modern-Ice" ]; then
        echo "  -> Bibata-Modern-Ice already installed, skipping"
        return
    fi

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
        cp -r "$TMP_DIR/Bibata-Modern-Ice" "$CURSOR_DIR_LOCAL/"
        echo "  -> Bibata cursor theme installed"
    elif [ -d "$TMP_DIR"/Bibata* ]; then
        cp -r "$TMP_DIR"/Bibata* "$CURSOR_DIR/"
        cp -r "$TMP_DIR"/Bibata* "$CURSOR_DIR_LOCAL/"
        echo "  -> Bibata cursor theme installed"
    else
        echo "  -> Could not find Bibata cursor theme in archive"
        ls -la "$TMP_DIR/" 2>/dev/null || true
    fi

    if command -v dconf &> /dev/null; then
        dconf write /org/gnome/desktop/interface/cursor-theme "'Bibata-Modern-Ice'" || true
        echo "  -> Cursor theme set to Bibata-Modern-Ice"
    fi
}

install_mactahoe
echo ""
install_bibata

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "Themes installation complete!"
echo ""
echo "To apply themes, use GNOME Tweaks or run:"
echo "  dconf write /org/gnome/desktop/interface/gtk-theme \"'MacTahoe-Light-purple'\""
echo "  dconf write /org/gnome/shell/extensions/user-theme/name \"'MacTahoe-Light-purple'\""
echo "  dconf write /org/gnome/desktop/interface/cursor-theme \"'Bibata-Modern-Ice'\""
