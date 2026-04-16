#!/bin/bash

# Fonts Installation Script
# Installs:
# - Nasalization (Display font)
# - Inter (Variable font)
# - FiraMono Nerd Font (Monospace)

set -e

FONT_DIR="$HOME/.local/share/fonts"
FONT_CONFIG_DIR="$HOME/.config/fontconfig"

mkdir -p "$FONT_DIR"
mkdir -p "$FONT_CONFIG_DIR"

# Array of fonts to install from local source
FONTS=(
    "Nasalization Rg.otf"
    "Inter-VariableFont_opsz,wght.ttf"
    "FiraMonoNerdFont-Regular.otf"
    "Amped OTF.otf"
)

install_font() {
    local font_name="$1"
    echo "Installing font: $font_name"

    # Check in common local font locations
    local found=false
    local source=""

    for dir in "$HOME/Downloads" "$HOME/.local/share/fonts" "$HOME/.fonts" "$HOME/Documents"; do
        if [ -f "$dir/$font_name" ]; then
            source="$dir/$font_name"
            found=true
            break
        fi
    done

    if [ "$found" = true ]; then
        cp "$source" "$FONT_DIR/"
        echo "  -> Copied from: $source"
    else
        echo "  -> Font file not found locally"
        echo "  -> Place font files in ~/.local/share/fonts/ or Downloads/"
    fi
}

echo "Installing Fonts..."
echo ""

for font in "${FONTS[@]}"; do
    install_font "$font"
done

echo ""
echo "Refreshing font cache..."
fc-cache -f -v > /dev/null 2>&1 || true

echo ""
echo "Fonts installation complete!"
echo ""
echo "Installed fonts:"
fc-list | grep -iE "nasalization|inter|firamono|amped" || echo "  (Run 'fc-list' to list all fonts)"

echo ""
echo "To use these fonts, configure in:"
echo "  - GNOME Tweaks > Fonts"
echo "  - Application settings"
echo "  - Terminal preferences"
