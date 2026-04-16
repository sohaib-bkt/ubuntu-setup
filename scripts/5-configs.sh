#!/bin/bash

# Dconf Configuration Script
# Applies all GNOME interface settings

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$REPO_DIR/config"
BACKUP_DIR="$HOME/.config/backup/dconf/$(date +%Y%m%d_%H%M%S)"

mkdir -p "$BACKUP_DIR"

echo "Applying Dconf Configuration..."
echo ""

# Backup current dconf settings
echo "Backing up current settings to: $BACKUP_DIR"
dconf dump /org/gnome/ > "$BACKUP_DIR/gnome-backup.ini" 2>/dev/null || true

# Apply interface settings
echo "Applying interface settings..."

dconf write /org/gnome/desktop/interface/color-scheme "'default'"
dconf write /org/gnome/desktop/interface/cursor-theme "'Bibata-Modern-Ice'"
dconf write /org/gnome/desktop/interface/document-font-name "'Inter 11'"
dconf write /org/gnome/desktop/interface/enable-animations true
dconf write /org/gnome/desktop/interface/font-hinting "'slight'"
dconf write /org/gnome/desktop/interface/font-name "'Nasalization 11'"
dconf write /org/gnome/desktop/interface/gtk-theme "'MacTahoe-Light-purple'"
dconf write /org/gnome/desktop/interface/icon-theme "'Gruvbox-Plus-Light'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'Inter 13'"
dconf write /org/gnome/desktop/interface/text-scaling-factor 1.08

echo "  -> Interface settings applied"

# Apply shell extension settings
echo "Applying shell extension settings..."

# User theme
dconf write /org/gnome/shell/extensions/user-theme/name "'MacTahoe-Light-purple'"

# Dash to Dock settings
dconf write /org/gnome/shell/extensions/dash-to-dock/apply-custom-theme false
dconf write /org/gnome/shell/extensions/dash-to-dock/background-opacity 0.0
dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-shrink true
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 44
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
dconf write /org/gnome/shell/extensions/dash-to-dock/height-fraction 0.9
dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide-mode "'FOCUS_APPLICATION_WINDOWS'"
dconf write /org/gnome/shell/extensions/dash-to-dock/preferred-monitor -2
dconf write /org/gnome/shell/extensions/dash-to-dock/preferred-monitor-by-connector "'eDP-1'"
dconf write /org/gnome/shell/extensions/dash-to-dock/preview-size-scale 0.11
dconf write /org/gnome/shell/extensions/dash-to-dock/transparency-mode "'FIXED'"
dconf write /org/gnome/shell/extensions/dash-to-dock/workspace-agnostic-urgent-windows true

# Custom window controls
dconf write /org/gnome/shell/extensions/custom-window-controls/button-layout 2
dconf write /org/gnome/shell/extensions/custom-window-controls/traffic-light-colors true

# Openbar
dconf write /org/gnome/shell/extensions/openbar/monitor-width 1920
dconf write /org/gnome/shell/extensions/openbar/monitor-height 1080

# P7 Borders
dconf write /org/gnome/shell/extensions/p7-borders/default-enabled true
dconf write /org/gnome/shell/extensions/p7-borders/default-radius 7
dconf write /org/gnome/shell/extensions/p7-borders/default-width 7
dconf write /org/gnome/shell/extensions/p7-borders/default-margins 6

# Tiling Assistant
dconf write /org/gnome/shell/extensions/tiling-assistant/active-window-hint 1
dconf write /org/gnome/shell/extensions/tiling-assistant/tiling-popup-all-workspace true

# Just Perfection
dconf write /org/gnome/shell/extensions/just-perfection/clock-menu true
dconf write /org/gnome/shell/extensions/just-perfection/ripple-box true
dconf write /org/gnome/shell/extensions/just-perfection/window-menu true
dconf write /org/gnome/shell/extensions/just-perfection/workspaces-in-app-grid true

# Volume Scroller
dconf write /org/gnome/shell/extensions/volume-scroller/granularity 5

# Forge
dconf write /org/gnome/shell/extensions/forge/keybindings/window-toggle-float "['<Super>c']"
dconf write /org/gnome/shell/extensions/forge/keybindings/window-snap-center "['<Control><Alt>c']"

# Blur My Shell
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/blur true
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/opacity 79
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/blur true
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/blur true
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/static-blur true

echo "  -> Shell extension settings applied"

# Create symbolic link to backup
ln -sf "$BACKUP_DIR/gnome-backup.ini" "$HOME/.config/backup/latest-dconf-backup.ini" 2>/dev/null || true

echo ""
echo "Dconf configuration complete!"
echo ""
echo "Backup saved to: $BACKUP_DIR"
echo ""
echo "To reset to defaults, run:"
echo "  dconf reset -f /org/gnome/"
