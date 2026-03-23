#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
backup()  { echo -e "${YELLOW}[→]${NC} Backup: $*"; }

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/$1"

  if [ ! -e "$src" ]; then
    warn "Source not found: $src"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      info "Already linked: $dst"
      return
    fi
    mkdir -p "$BACKUP_DIR/$(dirname "$1")"
    mv "$dst" "$BACKUP_DIR/$1"
    backup "$dst → $BACKUP_DIR/$1"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  info "Linked: $dst → $src"
}

echo "Dotfiles installer"
echo "Repo: $DOTFILES"
echo ""

# Shell
link .zshrc

# Hyprland
link .config/hypr

# Terminal
link .config/kitty

# Tmux
link .config/tmux

# Neovim
link .config/nvim

# Waybar
link .config/waybar

# Fastfetch
link .config/fastfetch

# Starship
link .config/starship.toml

# Scripts
link .local/bin/switch-flavor
link .local/bin/dev

echo ""
if [ -d "$BACKUP_DIR" ]; then
  echo "Backups saved to: $BACKUP_DIR"
fi
echo "Done!"
