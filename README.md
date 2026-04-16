# Ubuntu Setup

Automated setup script for my Ubuntu GNOME desktop customization.

## What's Included

- **Themes:** GTK, Shell, and cursor themes
- **Icons:** Custom icon packs
- **Fonts:** Custom typography
- **Extensions:** GNOME shell extensions with full configuration
- **Configs:** Dconf settings for interface customization

## Quick Start

```bash
git clone https://github.com/sohaibbkt/ubuntu-setup.git
cd ubuntu-setup
chmod +x setup.sh
./setup.sh
```

## Interactive Mode

The script will ask you which components to install:
- Extensions
- Themes
- Icons
- Fonts
- All of the above

## Individual Scripts

You can also run individual scripts:

```bash
./scripts/1-extensions.sh    # Install GNOME extensions
./scripts/2-themes.sh       # Install themes
./scripts/3-icons.sh         # Install icon packs
./scripts/4-fonts.sh         # Install fonts
./scripts/5-configs.sh        # Apply dconf settings
```

## Requirements

- Ubuntu 22.04+ (Jammy or later)
- GNOME 42+
- `dconf` CLI tool
- `git`

## Extensions Installed

- blur-my-shell
- custom-window-controls
- dash-to-dock
- ding
- forge
- just-perfection
- openbar
- p7-borders
- tiling-assistant
- ubuntu-appindicators
- ubuntu-dock
- volume-scroller

## Themes

- **GTK:** MacTahoe-Light-purple
- **Icons:** Gruvbox-Plus-Light
- **Cursor:** Bibata-Modern-Ice
- **Shell:** MacTahoe-Light-purple

## Fonts

- Nasalization
- Inter (Variable)

## Notes

- Backups of existing configs are saved to `~/.config/backup/`
- Dconf settings are applied via `dconf load`
- Themes/icons are installed to `~/.themes/` and `~/.icons/`
