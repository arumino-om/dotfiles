#!/usr/bin/env bash
set -euo pipefail

brew_formulae=(
  eza
  mise
  starship
  zsh-autosuggestions
  zsh-syntax-highlighting
  ghq
  gnupg
  pinentry-mac
)

brew_casks=(
  visual-studio-code
  docker
  discord
)

log() {
  local level="${2:-INFO}"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$timestamp][$level] $1"
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew is already installed." "INFO"
  else
    log "Installing Homebrew..." "INFO"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log "Homebrew installation completed." "SUCCESS"
  fi
}

install_formulae() {
  log "Installing Homebrew formulae..." "INFO"
  for pkg in "${brew_formulae[@]}"; do
    if brew list "$pkg" >/dev/null 2>&1; then
      log " - $pkg already installed" "INFO"
    else
      log " - installing $pkg" "INFO"
      brew install "$pkg"
      log " - $pkg installed" "SUCCESS"
    fi
  done
}

install_casks() {
  log "Installing Homebrew casks..." "INFO"
  for app in "${brew_casks[@]}"; do
    if brew list --cask "$app" >/dev/null 2>&1; then
      log " - $app already installed" "INFO"
    else
      log " - installing $app" "INFO"
      brew install --cask "$app"
      log " - $app installed" "SUCCESS"
    fi
  done
}

setup_zshrc() {
  local dotfiles_dir="${DOTFILES_DIR:-$HOME/dotfiles}"
  local zshrc="$HOME/.zshrc"

  log "Configuring ~/.zshrc ..." "INFO"

  touch "$zshrc"

  cp 
}

main() {
  install_homebrew
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew update

  install_formulae
  install_casks
  setup_zshrc

  log "macOS setup completed." "SUCCESS"
}

main "$@"