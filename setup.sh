#!/bin/bash

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Ubuntu Desktop Setup"
echo "=========================================="
echo ""

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    echo "Error: This script is designed for Ubuntu."
    exit 1
fi

# Check for required tools
check_dependencies() {
    echo "Checking dependencies..."
    local deps=("dconf" "git")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Installing $dep..."
            sudo apt-get update && sudo apt-get install -y "$dep"
        fi
    done
    echo "Dependencies OK."
    echo ""
}

check_dependencies

# Interactive menu
show_menu() {
    echo "Select components to install:"
    echo ""
    echo "  [1] Extensions"
    echo "  [2] Themes"
    echo "  [3] Icons"
    echo "  [4] Fonts"
    echo "  [5] Configs (dconf settings)"
    echo "  [a] All of the above"
    echo "  [q] Quit"
    echo ""
}

# Parse arguments for non-interactive mode
INSTALL_ALL=false
INSTALL_EXTENSIONS=false
INSTALL_THEMES=false
INSTALL_ICONS=false
INSTALL_FONTS=false
INSTALL_CONFIGS=false

if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Enter your choice (1-5, a, or q): " choice
        case $choice in
            1) INSTALL_EXTENSIONS=true; break ;;
            2) INSTALL_THEMES=true; break ;;
            3) INSTALL_ICONS=true; break ;;
            4) INSTALL_FONTS=true; break ;;
            5) INSTALL_CONFIGS=true; break ;;
            a|A) INSTALL_ALL=true; break ;;
            q|Q) echo "Exiting."; exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
else
    # Non-interactive mode with arguments
    for arg in "$@"; do
        case $arg in
            --extensions|-e) INSTALL_EXTENSIONS=true ;;
            --themes|-t) INSTALL_THEMES=true ;;
            --icons|-i) INSTALL_ICONS=true ;;
            --fonts|-f) INSTALL_FONTS=true ;;
            --configs|-c) INSTALL_CONFIGS=true ;;
            --all|-a) INSTALL_ALL=true ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --extensions, -e    Install GNOME extensions"
                echo "  --themes, -t        Install themes"
                echo "  --icons, -i         Install icon packs"
                echo "  --fonts, -f         Install fonts"
                echo "  --configs, -c       Apply dconf settings"
                echo "  --all, -a           Install everything"
                echo "  --help, -h          Show this help"
                exit 0
                ;;
        esac
    done
fi

# If --all, enable all components
if [ "$INSTALL_ALL" = true ]; then
    INSTALL_EXTENSIONS=true
    INSTALL_THEMES=true
    INSTALL_ICONS=true
    INSTALL_FONTS=true
    INSTALL_CONFIGS=true
fi

# Create backup directory
BACKUP_DIR="$HOME/.config/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Run the selected scripts
if [ "$INSTALL_EXTENSIONS" = true ]; then
    echo ""
    echo ">>> Installing GNOME extensions..."
    "$REPO_DIR/scripts/1-extensions.sh"
fi

if [ "$INSTALL_THEMES" = true ]; then
    echo ""
    echo ">>> Installing themes..."
    "$REPO_DIR/scripts/2-themes.sh"
fi

if [ "$INSTALL_ICONS" = true ]; then
    echo ""
    echo ">>> Installing icons..."
    "$REPO_DIR/scripts/3-icons.sh"
fi

if [ "$INSTALL_FONTS" = true ]; then
    echo ""
    echo ">>> Installing fonts..."
    "$REPO_DIR/scripts/4-fonts.sh"
fi

if [ "$INSTALL_CONFIGS" = true ]; then
    echo ""
    echo ">>> Applying dconf configurations..."
    "$REPO_DIR/scripts/5-configs.sh"
fi

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Note: You may need to log out and log back in"
echo "or restart GNOME Shell for all changes to take effect."
echo ""
echo "To restart GNOME Shell, press: Alt+F2, then type 'r', then Enter"
