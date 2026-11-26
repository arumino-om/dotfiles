#!/bin/bash
# ===== BOOTSTRAP SCRIPT =====
# まだリポジトリが無いマシン向けの入口
#   1. Homebrew のインストール (macOS．Command Line Tools も同時に入る)
#   2. git, gh のインストール
#   3. gh の認証 ($GH_TOKEN があればそれを保存，無ければ対話ログイン) と git への認証設定
#   4. dotfiles を clone (済みなら pull) して install.sh を実行
#
# 使い方 (private リポジトリのため API 経由でトークン付き取得):
#   read -rs GH_TOKEN && export GH_TOKEN
#   curl -fsSL -H "Authorization: Bearer $GH_TOKEN" -H "Accept: application/vnd.github.raw" \
#     https://api.github.com/repos/arumino-om/dotfiles/contents/bootstrap.sh | bash
# ============================

# パイプ実行で途中までしか受信できなかった場合に中途半端に動かないよう，
# 全体を関数に包んで最後に呼び出す

REPO="arumino-om/dotfiles"

# curl | bash だと標準入力がパイプなので，対話が必要なコマンドは端末から入力させる
run_tty() {
    if [ ! -t 0 ] && { true </dev/tty; } 2>/dev/null; then
        "$@" </dev/tty
    else
        "$@"
    fi
}

ensure_homebrew() {
    local brew_bin
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_bin" ]; then
            eval "$("$brew_bin" shellenv)"
            return 0
        fi
    done

    echo "install: Homebrew"
    run_tty /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ensure_homebrew
}

ensure_tools() {
    if [ "$(uname)" = "Darwin" ]; then
        ensure_homebrew
        local pkg
        for pkg in git gh; do
            brew list --formula "$pkg" >/dev/null 2>&1 || brew install "$pkg"
        done
    fi

    local cmd
    for cmd in git gh; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "$cmd が見つかりません．インストールしてから再実行してください" >&2
            exit 1
        fi
    done
}

# gh の認証情報を保存し，git の認証にも gh を使わせる
# (GH_TOKEN が環境変数にあると gh auth login は保存を拒否するため外して実行)
ensure_gh_auth() {
    if env -u GH_TOKEN gh auth status >/dev/null 2>&1; then
        echo "auth:   gh はログイン済み"
    elif [ -n "${GH_TOKEN:-}" ]; then
        echo "auth:   GH_TOKEN で gh にログイン"
        printf '%s\n' "$GH_TOKEN" | env -u GH_TOKEN gh auth login --hostname github.com --with-token
    else
        echo "auth:   gh に対話ログイン"
        run_tty env -u GH_TOKEN gh auth login --hostname github.com --git-protocol https --web
    fi

    env -u GH_TOKEN gh auth setup-git --hostname github.com
}

main() {
    set -euo pipefail

    local dest="${DOTFILES_DIR:-$HOME/ghq/github.com/$REPO}" # ghq の配置に合わせる

    ensure_tools
    ensure_gh_auth

    if [ -d "$dest/.git" ]; then
        echo "pull:   $dest"
        git -C "$dest" pull --ff-only
    else
        echo "clone:  $REPO -> $dest"
        mkdir -p "$(dirname "$dest")"
        git clone "https://github.com/$REPO.git" "$dest"
    fi

    # 認証は保存済みなので以降の処理にトークンを引き継がない
    unset GH_TOKEN
    run_tty "$dest/install.sh"
}

main "$@"
