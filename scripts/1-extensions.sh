#!/bin/bash

# GNOME Shell Extensions Installation Script
# Extensions installed:
# - blur-my-shell
# - custom-window-controls
# - dash-to-dock
# - ding
# - forge
# - just-perfection
# - openbar
# - p7-borders
# - tiling-assistant
# - ubuntu-appindicators
# - ubuntu-dock
# - volume-scroller

set -e

EXTENSIONS=(
    "blur-my-shell@aunetx"
    "custom-window-controls@mattr4y"
    "dash-to-dock@micahg"
    "ding@rastersoft.com"
    "forge@jmmaranan.com"
    "just-perfection@just-perfection"
    "openbar@ob"
    "p7-borders@YashPm"
    "tiling-assistant@Ubuntu.com"
    "ubuntu-appindicators@ubuntu.com"
    "ubuntu-dock@ubuntu.com"
    "volume-scroller@exti"
)

GNOME_EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
TMP_BASE="/tmp/ubuntu-setup-extensions"
USER_THEMES_UUID="user-theme@gnome-shell-extensions.gcampax.github.com"

mkdir -p "$GNOME_EXTENSIONS_DIR"
mkdir -p "$TMP_BASE"

# Install gnome-extensions-cli if not available
install_gext_cli() {
    if ! command -v gext &> /dev/null; then
        echo "Installing gnome-extensions-cli (gext)..."
        if command -v pip3 &> /dev/null; then
            pip3 install --upgrade gnome-extensions-cli 2>/dev/null || \
            sudo pip3 install --upgrade gnome-extensions-cli 2>/dev/null || true
        fi
        if command -v gext &> /dev/null; then
            echo "  -> gext installed successfully"
        fi
    fi
}

# First install user-themes extension (required for shell themes)
install_user_themes_extension() {
    echo "Installing User Themes extension (required for shell themes)..."
    if [ -d "$GNOME_EXTENSIONS_DIR/$USER_THEMES_UUID" ]; then
        echo "  -> User Themes already installed"
    else
        if command -v gext &> /dev/null; then
            gext install "$USER_THEMES_UUID" 2>/dev/null || {
                # Manual install for user-themes
                local zip_url="https://extensions.gnome.org/extension-data/user-theme@gnome-shell-extensions.gcampax.github.com.v46.shell-extension.zip"
                wget -q -O "$TMP_BASE/user-theme.zip" "$zip_url" 2>/dev/null || true
                if [ -f "$TMP_BASE/user-theme.zip" ]; then
                    unzip -q "$TMP_BASE/user-theme.zip" -d "$TMP_BASE/user-theme-extracted"
                    mkdir -p "$GNOME_EXTENSIONS_DIR/$USER_THEMES_UUID"
                    cp -r "$TMP_BASE/user-theme-extracted/"* "$GNOME_EXTENSIONS_DIR/$USER_THEMES_UUID/" 2>/dev/null || true
                fi
            }
        else
            # Fallback manual install
            local zip_url="https://extensions.gnome.org/extension-data/user-theme@gnome-shell-extensions.gcampax.github.com.v46.shell-extension.zip"
            wget -q -O "$TMP_BASE/user-theme.zip" "$zip_url" 2>/dev/null || true
            if [ -f "$TMP_BASE/user-theme.zip" ]; then
                unzip -q "$TMP_BASE/user-theme.zip" -d "$TMP_BASE/user-theme-extracted"
                mkdir -p "$GNOME_EXTENSIONS_DIR/$USER_THEMES_UUID"
                cp -r "$TMP_BASE/user-theme-extracted/"* "$GNOME_EXTENSIONS_DIR/$USER_THEMES_UUID/" 2>/dev/null || true
            fi
        fi
    fi
    # Enable user-themes extension
    gnome-extensions enable "$USER_THEMES_UUID" 2>/dev/null || true
}

get_download_url() {
    local ext="$1"
    case "$ext" in
        blur-my-shell@aunetx)
            echo "https://extensions.gnome.org/extension-data/blur-my-shellaunetx.v46.shell-extension.zip"
            ;;
        custom-window-controls@mattr4y)
            echo "https://extensions.gnome.org/extension-data/custom-window-controlsmattr4y.v24.shell-extension.zip"
            ;;
        dash-to-dock@micahg)
            echo "https://extensions.gnome.org/extension-data/dash-to-dockmicahg.github.com.v78.shell-extension.zip"
            ;;
        ding@rastersoft.com)
            echo "https://extensions.gnome.org/extension-data/dingrastersoft.com.v67.shell-extension.zip"
            ;;
        forge@jmmaranan.com)
            echo "https://extensions.gnome.org/extension-data/forgedmmaranan.com.v52.shell-extension.zip"
            ;;
        just-perfection@just-perfection)
            echo "https://extensions.gnome.org/extension-data/just-perfectionjust-perfection.v22.shell-extension.zip"
            ;;
        openbar@ob)
            echo "https://extensions.gnome.org/extension-data/openbarob.v60.shell-extension.zip"
            ;;
        p7-borders@YashPm)
            echo "https://extensions.gnome.org/extension-data/p7-bordersYashPm.v20.shell-extension.zip"
            ;;
        tiling-assistant@Ubuntu.com)
            echo "https://extensions.gnome.org/extension-data/tiling-assistantUbuntu.com.v46.shell-extension.zip"
            ;;
        ubuntu-appindicators@ubuntu.com)
            echo "https://extensions.gnome.org/extension-data/ubuntu-appindicatorsubuntu.com.v87.shell-extension.zip"
            ;;
        ubuntu-dock@ubuntu.com)
            echo "https://extensions.gnome.org/extension-data/ubuntu-dockubuntu.com.v68.shell-extension.zip"
            ;;
        volume-scroller@exti)
            echo "https://extensions.gnome.org/extension-data/volume-scrollerexti.v14.shell-extension.zip"
            ;;
        *)
            echo ""
            ;;
    esac
}

install_extension() {
    local uuid="$1"
    local tmp_dir="$TMP_BASE/$uuid"
    mkdir -p "$tmp_dir"

    echo "Installing: $uuid"

    # Check if already installed by checking directory exists
    if [ -d "$GNOME_EXTENSIONS_DIR/$uuid" ]; then
        echo "  -> Already installed, skipping"
        return
    fi

    local zip_url
    zip_url="$(get_download_url "$uuid")"

    if [ -n "$zip_url" ]; then
        echo "  -> Downloading extension package..."
        if ! wget -q --show-progress -O "$tmp_dir/extension.zip" "$zip_url" 2>/dev/null; then
            echo "  -> Failed to download extension from $zip_url"
            return
        fi
    fi

    if [ -f "$tmp_dir/extension.zip" ]; then
        # Clean up any existing installation
        rm -rf "$GNOME_EXTENSIONS_DIR/$uuid"
        mkdir -p "$GNOME_EXTENSIONS_DIR/$uuid"

        # Extract to temp location
        rm -rf "$tmp_dir/extracted"
        unzip -q "$tmp_dir/extension.zip" -d "$tmp_dir/extracted"

        # Find and copy extension files
        if [ -d "$tmp_dir/extracted/$uuid" ]; then
            cp -r "$tmp_dir/extracted/$uuid/"* "$GNOME_EXTENSIONS_DIR/$uuid/"
        elif [ -d "$tmp_dir/extracted/extensions" ]; then
            # Handle nested extensions directory
            cp -r "$tmp_dir/extracted/extensions/$uuid/"* "$GNOME_EXTENSIONS_DIR/$uuid/" 2>/dev/null || \
            cp -r "$tmp_dir/extracted/"* "$GNOME_EXTENSIONS_DIR/$uuid/"
        else
            # Copy whatever is there
            cp -r "$tmp_dir/extracted/"* "$GNOME_EXTENSIONS_DIR/$uuid/"
        fi

        if [ -f "$GNOME_EXTENSIONS_DIR/$uuid/metadata.json" ]; then
            echo "  -> Installed to $GNOME_EXTENSIONS_DIR/$uuid"
        else
            echo "  -> Warning: metadata.json not found, extension may not be properly installed"
            ls -la "$GNOME_EXTENSIONS_DIR/$uuid/" 2>/dev/null || true
        fi
    else
        echo "  -> No extension package available; skipping $uuid"
    fi
}

echo "Installing GNOME Shell Extensions..."
echo ""

# Install gext CLI tool
install_gext_cli

# Install user-themes first (required for shell themes)
install_user_themes_extension

echo ""
echo "Installing extensions..."
for ext in "${EXTENSIONS[@]}"; do
    install_extension "$ext"
done

echo ""
echo "Enabling extensions..."
# Enable user-themes first
gnome-extensions enable "$USER_THEMES_UUID" 2>/dev/null || true

# Enable all extensions
for ext in "${EXTENSIONS[@]}"; do
    if [ -d "$GNOME_EXTENSIONS_DIR/$ext" ]; then
        gnome-extensions enable "$ext" 2>/dev/null && echo "  -> Enabled: $ext" || echo "  -> Failed to enable: $ext"
    fi
done

echo ""
echo "Extensions installation complete!"
echo ""
echo "Installed extensions:"
ls -la "$GNOME_EXTENSIONS_DIR/" 2>/dev/null || echo "  (No extensions found)"
echo ""
echo "Note: Some extensions may require GNOME Shell restart to take effect."
echo "To restart GNOME Shell, press: Alt+F2, then type 'r', then Enter"
