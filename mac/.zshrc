autoload -Uz compinit && compinit

# zshのカスタマイズ
eval "$(starship init zsh)"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
setopt auto_cd
setopt cdable_vars

# 補完動作の設定
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
compdef eza=ls

# エイリアス
alias ls="eza --icons"
alias ll="eza -l --icons"
alias la="eza -la --icons"

# ツールのアクティブ化
export EMSDK_QUIET=1
eval "$($HOME/.local/bin/mise activate zsh)"
source "$HOME/emsdk/emsdk_env.sh"
