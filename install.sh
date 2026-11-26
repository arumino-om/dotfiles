#!/bin/bash
# ===== ENVIRONMENT INSTALL SCRIPT (ENTRY) =====
# POSIX互換OS用の共通エントリポイント
#   1. 外部dotfilesの取得 ($EXTERNAL_DOTFILES_REPO が設定されていれば)
#   2. OS専用スクリプトの実行 (darwin: install-mac.sh)
#   3. packages[-<os>]/git-repos.txt に記載のリポジトリを git clone
#   4. home/ と home-<os>/ 以下を $HOME に同じ相対パスでシンボリックリンク
#        例) <repo>/home/.config/git/config -> ~/.config/git/config
#      既存の通常ファイルは ~/.dotfiles_backup/<日時>/ に退避する
# external/ に同じ構成があれば後から処理するため，外部dotfiles側が優先される
# <os> は uname を小文字にしたもの (darwin, linux, ...)
# ==============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTERNAL_DIR="$SCRIPT_DIR/external"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
OS="$(uname | tr '[:upper:]' '[:lower:]')"

# 処理対象のルート (後ろほど優先)
ROOTS=("$SCRIPT_DIR" "$EXTERNAL_DIR")

# ----- git -----

# GH_TOKEN があれば github.com への認証にそれを使って git を実行する
# (Codespaces の GITHUB_TOKEN は他のプライベートリポジトリを読めないため)
# git の設定ファイルは変更せず，このコマンド実行時だけ認証ヘルパーを差し替える
git_auth() {
    if [ -n "${GH_TOKEN:-}" ]; then
        git -c credential.https://github.com.helper= \
            -c 'credential.https://github.com.helper=!f() { [ "$1" = get ] && printf "username=x-access-token\npassword=%s\n" "$GH_TOKEN"; }; f' \
            "$@"
    else
        git "$@"
    fi
}

# ----- packages -----

# $1: git-repos.txt のパス
# 書式: <リポジトリURL> <クローン先 ($HOME からの相対パス)>
install_git_repos() {
    local list="$1" url dest
    [ -f "$list" ] || return 0

    while read -r url dest _ || [ -n "$url" ]; do
        case "$url" in '' | '#'*) continue ;; esac
        if [ -z "$dest" ]; then
            echo "skip:   クローン先がありません: $url" >&2
            continue
        fi

        if [ -e "$HOME/$dest" ]; then
            echo "exists: ~/$dest"
        else
            echo "clone:  $url -> ~/$dest"
            git clone --depth=1 "$url" "$HOME/$dest"
        fi
    done <"$list"
}

# ----- dotfiles -----

# $1: リンク元 (リポジトリ内の絶対パス)  $2: リンク先 ($HOME 以下)
link_file() {
    local src="$1" dst="$2"

    if [ -L "$dst" ] && [[ "$(readlink "$dst")" == "$SCRIPT_DIR"/* ]]; then
        # このリポジトリ(external含む)が張ったリンクなので張り直すだけ
        rm "$dst"
    elif [ -e "$dst" ] || [ -L "$dst" ]; then
        local rel="${dst#"$HOME"/}"
        mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
        mv "$dst" "$BACKUP_DIR/$rel"
        echo "backup: $dst -> $BACKUP_DIR/$rel"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "link:   $dst -> $src"
}

# $1: $HOME に対応するディレクトリ
link_tree() {
    local root="$1"
    [ -d "$root" ] || return 0

    (cd "$root" && find . \( -type f -o -type l \) ! -name '.DS_Store' -print0) |
        while IFS= read -r -d '' rel; do
            rel="${rel#./}"
            link_file "$root/$rel" "$HOME/$rel"
        done
}

# ----- main -----

# 1. 外部dotfiles (リンク時に優先させるため先に取得)
if [ -n "${EXTERNAL_DOTFILES_REPO:-}" ]; then
    if [ -d "$EXTERNAL_DIR/.git" ]; then
        git_auth -C "$EXTERNAL_DIR" pull --ff-only
    else
        git_auth clone "$EXTERNAL_DOTFILES_REPO" "$EXTERNAL_DIR"
    fi
fi

# 2. OS専用の処理 (パッケージマネージャ等)
case "$OS" in
    darwin) "$SCRIPT_DIR/install-mac.sh" ;;
    *) echo "info:   $OS 専用のセットアップはありません (リンクのみ行います)" ;;
esac

# 3, 4. OS共通 → OS専用 の順で処理
for root in "${ROOTS[@]}"; do
    install_git_repos "$root/packages/git-repos.txt"
    install_git_repos "$root/packages-$OS/git-repos.txt"
done

for root in "${ROOTS[@]}"; do
    link_tree "$root/home"
    link_tree "$root/home-$OS"
done

# 外部dotfiles独自のセットアップ処理があれば実行する
# (外部側が同じ構成のスクリプトでも再帰cloneしないよう変数を外す)
if [ -x "$EXTERNAL_DIR/install.sh" ]; then
    env -u EXTERNAL_DOTFILES_REPO "$EXTERNAL_DIR/install.sh"
fi
