#!/bin/bash
# ===== macOS SETUP SCRIPT =====
# install.sh から呼ばれる macOS 専用の処理
#   - Homebrew が無ければインストール
#   - packages-darwin/Brewfile を brew bundle でインストール
# git clone やリンクは install.sh 側で OS 共通に行う
# ================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 処理対象のルート (後ろほど優先)
ROOTS=("$SCRIPT_DIR" "$SCRIPT_DIR/external")

ensure_homebrew() {
    local brew_bin
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_bin" ]; then
            eval "$("$brew_bin" shellenv)"
            return 0
        fi
    done

    echo "install: Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ensure_homebrew
}

# $1: Brewfile のパス
install_brewfile() {
    local brewfile="$1"
    [ -f "$brewfile" ] || return 0

    ensure_homebrew
    echo "brew:   $brewfile"
    brew bundle --file="$brewfile"
}

for root in "${ROOTS[@]}"; do
    install_brewfile "$root/packages-darwin/Brewfile"
done
