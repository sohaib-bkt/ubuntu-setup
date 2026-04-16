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

install_extension() {
    local ext="$1"
    echo "Installing: $ext"

    if gnome-extensions list | grep -q "^${ext}"; then
        echo "  -> Already installed, skipping"
        return
    fi

    # Try installing via gnome-extensions CLI first
    if gnome-extensions install "$ext" 2>/dev/null; then
        echo "  -> Installed via gnome-extensions CLI"
        return
    fi

    # Fallback: download and install from GitHub
    echo "  -> Trying alternative installation method..."

    # Extract extension UUID from package name
    local uuid="${ext}"
    local zip_url=""

    case "$ext" in
        *@aunetx)
            zip_url="https://extensions.gnome.org/extension-data/blur-my-shellaunetx.v46.shell-extension.zip"
            ;;
        *@mattr4y)
            zip_url="https://extensions.gnome.org/extension-data/custom-window-controlsmattr4y.v24.shell-extension.zip"
            ;;
        *@micahg)
            zip_url="https://extensions.gnome.org/extension-data/dash-to-dockmicahg.github.com.v78.shell-extension.zip"
            ;;
        *@rastersoft.com)
            zip_url="https://extensions.gnome.org/extension-data/dingrastersoft.com.v67.shell-extension.zip"
            ;;
        *@jmmaranan.com)
            zip_url="https://extensions.gnome.org/extension-data/forgedmmaranan.com.v52.shell-extension.zip"
            ;;
        *@just-perfection)
            zip_url="https://extensions.gnome.org/extension-data/just-perfectionjust-perfection.v22.shell-extension.zip"
            ;;
        *@ob)
            zip_url="https://extensions.gnome.org/extension-data/openbarob.v60.shell-extension.zip"
            ;;
        *@YashPm)
            zip_url="https://extensions.gnome.org/extension-data/p7-bordersYashPm.v20.shell-extension.zip"
            ;;
        *@Ubuntu.com)
            zip_url="https://extensions.gnome.org/extension-data/tiling-assistantUbuntu.com.v46.shell-extension.zip"
            ;;
        *@ubuntu.com)
            zip_url="https://extensions.gnome.org/extension-data/ubuntu-appindicatorsubuntu.com.v87.shell-extension.zip"
            ;;
        *@exti)
            zip_url="https://extensions.gnome.org/extension-data/volume-scrollerexti.v14.shell-extension.zip"
            ;;
    esac

    if [ -n "$zip_url" ]; then
        local tmp_dir="/tmp/gnome-ext-install"
        mkdir -p "$tmp_dir"
        wget -q -O "$tmp_dir/ext.zip" "$zip_url" 2>/dev/null && \
            gnome-extensions install --force "$tmp_dir/ext.zip" 2>/dev/null && \
            echo "  -> Installed via download" || \
            echo "  -> Failed to install $ext"
        rm -rf "$tmp_dir"
    else
        echo "  -> Could not determine download URL"
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
