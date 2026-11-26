# dotfiles
my dotfiles

## Setup

新しいマシン (リポジトリ未取得):

```sh
read -rs GH_TOKEN && export GH_TOKEN   # トークンを入力 (履歴に残さない)
curl -fsSL -H "Authorization: Bearer $GH_TOKEN" -H "Accept: application/vnd.github.raw" \
  https://api.github.com/repos/arumino-om/dotfiles/contents/bootstrap.sh | bash
```

Homebrew (macOS) → git, gh → `gh auth login` (トークンを保存) → `~/ghq/github.com/arumino-om/dotfiles` に clone → `install.sh` の順に実行します (`DOTFILES_DIR` で clone 先を変更可)．
トークンは Fine-grained token で対象リポジトリの Contents: Read-only があれば十分です．

clone 済みの場合:

```sh
./install.sh
```

GitHub Codespaces では，Settings → Codespaces の dotfiles 設定でこのリポジトリを指定すると `install.sh` が自動実行されます．

## Layout

| パス | 内容 |
|---|---|
| `home/` | 全OS共通．`$HOME` に同じ相対パスでシンボリックリンクされる |
| `home-<os>/` | OS専用 (`darwin`, `linux`, ...) |
| `packages/git-repos.txt`, `packages-<os>/git-repos.txt` | git clone するリポジトリ (`<URL> <$HOMEからの相対パス>`) |
| `packages-darwin/Brewfile` | `brew bundle` でインストールするもの |

既存ファイルは `~/.dotfiles_backup/<日時>/` に退避されます．
`EXTERNAL_DOTFILES_REPO` を設定すると `external/` に clone し，同じ構成で上書き適用します (外部側が優先)．
