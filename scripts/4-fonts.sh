#!/bin/bash

# Fonts Installation Script
# Downloads and installs:
# - Nasalization (Display font) - from dafont.com
# - Inter (Variable font) - from GitHub
# - FiraMono Nerd Font (Monospace) - from GitHub

set -e

FONT_DIR="$HOME/.local/share/fonts"
TMP_DIR="/tmp/ubuntu-setup-fonts"

mkdir -p "$FONT_DIR"
mkdir -p "$TMP_DIR"

echo "Installing Fonts..."
echo ""

# Install Nasalization font from dafont
install_nasalization() {
    echo "Installing Nasalization font..."

    if fc-list | grep -qi "Nasalization"; then
        echo "  -> Nasalization already installed, skipping"
        return
    fi

    NASAL_URL="https://dl.dafont.com/dl/?f=nasalization"

    if command -v wget &> /dev/null; then
        echo "  -> Downloading Nasalization font..."
        wget -q --show-progress -O "$TMP_DIR/nasalization.zip" "$NASAL_URL" 2>/dev/null

        if [ -f "$TMP_DIR/nasalization.zip" ]; then
            echo "  -> Extracting..."
            unzip -q -o "$TMP_DIR/nasalization.zip" -d "$TMP_DIR/Nasalization" 2>/dev/null

            # Find the .otf or .ttf file
            if ls "$TMP_DIR/Nasalization"/*.otf &>/dev/null; then
                cp "$TMP_DIR/Nasalization"/*.otf "$FONT_DIR/"
                echo "  -> Nasalization font installed"
            elif ls "$TMP_DIR/Nasalization"/*.ttf &>/dev/null; then
                cp "$TMP_DIR/Nasalization"/*.ttf "$FONT_DIR/"
                echo "  -> Nasalization font installed"
            else
                # Try to find any font file
                find "$TMP_DIR/Nasalization" -name "*.otf" -o -name "*.ttf" 2>/dev/null | while read font_file; do
                    cp "$font_file" "$FONT_DIR/"
                    echo "  -> Installed: $(basename "$font_file")"
                done
            fi
        else
            echo "  -> Failed to download Nasalization"
        fi
    else
        echo "  -> wget not installed, cannot download Nasalization"
        echo "  -> Install wget with: sudo apt install wget"
    fi
}

# Install Inter font
install_inter() {
    echo "Installing Inter font..."

    if fc-list | grep -qi "Inter"; then
        echo "  -> Inter already installed, skipping"
        return
    fi

    INTER_URL="https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip"

    if command -v wget &> /dev/null; then
        echo "  -> Downloading Inter font..."
        wget -q --show-progress -O "$TMP_DIR/Inter.zip" "$INTER_URL" 2>/dev/null

        if [ -f "$TMP_DIR/Inter.zip" ]; then
            echo "  -> Extracting..."
            unzip -q -o "$TMP_DIR/Inter.zip" -d "$TMP_DIR/Inter" 2>/dev/null

            # Install Inter fonts
            if [ -d "$TMP_DIR/Inter/InterDesktop" ]; then
                cp "$TMP_DIR/Inter/InterDesktop"/*.otf "$FONT_DIR/" 2>/dev/null || true
            fi
            if [ -d "$TMP_DIR/Inter/Inter" ]; then
                cp "$TMP_DIR/Inter/Inter"/*.otf "$FONT_DIR/" 2>/dev/null || true
            fi
            cp "$TMP_DIR/Inter"/*.otf "$FONT_DIR/" 2>/dev/null || true

            echo "  -> Inter font installed"
        else
            echo "  -> Failed to download Inter"
        fi
    else
        echo "  -> wget not installed, cannot download Inter"
    fi
}

# Install FiraMono Nerd Font
install_firamono() {
    echo "Installing FiraMono Nerd Font..."

    if fc-list | grep -qi "FiraCode"; then
        echo "  -> FiraMono Nerd Font already installed, skipping"
        return
    fi

    FIRAMONO_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraMono.zip"

    if command -v wget &> /dev/null; then
        echo "  -> Downloading FiraMono Nerd Font..."
        wget -q --show-progress -O "$TMP_DIR/FiraMono.zip" "$FIRAMONO_URL" 2>/dev/null

        if [ -f "$TMP_DIR/FiraMono.zip" ]; then
            echo "  -> Extracting..."
            unzip -q -o "$TMP_DIR/FiraMono.zip" -d "$TMP_DIR/FiraMono" 2>/dev/null
            cp "$TMP_DIR/FiraMono"/*.otf "$FONT_DIR/" 2>/dev/null || true
            echo "  -> FiraMono Nerd Font installed"
        else
            echo "  -> Failed to download FiraMono"
        fi
    else
        echo "  -> wget not installed, cannot download FiraMono"
    fi
}

install_nasalization
echo ""
install_inter
echo ""
install_firamono

# Cleanup
rm -rf "$TMP_DIR"

# Refresh font cache
echo ""
echo "Refreshing font cache..."
fc-cache -f -v > /dev/null 2>&1 || true

echo ""
echo "Fonts installation complete!"
echo ""
echo "Installed fonts:"
fc-list | grep -iE "nasalization|inter|firamono" || echo "  (Run 'fc-list' to list all fonts)"

echo ""
echo "To use these fonts, configure in:"
echo "  - GNOME Tweaks > Fonts"
echo "  - Application settings"
echo "  - Terminal preferences"
