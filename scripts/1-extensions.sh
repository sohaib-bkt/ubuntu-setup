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

mkdir -p "$GNOME_EXTENSIONS_DIR"
mkdir -p "$TMP_BASE"

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

    if gnome-extensions list | grep -q "^${uuid}$"; then
        echo "  -> Already installed, skipping"
        return
    fi

    local zip_url
    zip_url="$(get_download_url "$uuid")"

    if [ -n "$zip_url" ]; then
        echo "  -> Downloading extension package..."
        if ! wget -q -O "$tmp_dir/extension.zip" "$zip_url" 2>/dev/null; then
            echo "  -> Failed to download extension from $zip_url"
        fi
    fi

    if [ -f "$tmp_dir/extension.zip" ]; then
        if gnome-extensions install --force "$tmp_dir/extension.zip" 2>/dev/null; then
            echo "  -> Installed via gnome-extensions CLI"
        else
            echo "  -> Falling back to manual install"
            rm -rf "$GNOME_EXTENSIONS_DIR/$uuid"
            mkdir -p "$GNOME_EXTENSIONS_DIR/$uuid"
            unzip -q "$tmp_dir/extension.zip" -d "$tmp_dir/extracted"
            if [ -d "$tmp_dir/extracted/$uuid" ]; then
                cp -r "$tmp_dir/extracted/$uuid/"* "$GNOME_EXTENSIONS_DIR/$uuid/"
            else
                cp -r "$tmp_dir/extracted/"* "$GNOME_EXTENSIONS_DIR/$uuid/"
            fi
            echo "  -> Installed manually to $GNOME_EXTENSIONS_DIR/$uuid"
        fi
    else
        echo "  -> No extension package available; skipping $uuid"
    fi
}

echo "Installing GNOME Shell Extensions..."
echo ""

for ext in "${EXTENSIONS[@]}"; do
    install_extension "$ext"
done

echo ""
echo "Enabling extensions..."
for ext in "${EXTENSIONS[@]}"; do
    gnome-extensions enable "$ext" 2>/dev/null || true
done

echo ""
echo "Extensions installation complete!"
echo "Note: Some extensions may require GNOME Shell restart to take effect."
