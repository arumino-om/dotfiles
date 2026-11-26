# dotfiles
my dotfiles

## Setup
クローンしていない場合は，下記ブートストラップを実行します．セットアップに必要な最低限のパッケージをインストールし，このリポジトリをクローンして `install.sh` を実行します．

```sh
curl -fsSL https://raw.githubusercontent.com/arumino-om/dotfiles/refs/heads/main/bootstrap.sh | bash
```

クローン済みの場合は，次のコマンドを実行します．

```sh
./install.sh
```

GitHub Codespaces では，Settings → Codespaces の dotfiles 設定でこのリポジトリを指定すると `install.sh` が自動実行されます．

### 環境変数
スクリプトは，次の環境変数を認識します．

|環境変数名|目的|
|---|---|
|`GH_TOKEN`|GitHubの認証に使用します．`bootstrap.sh` では gh にログインして保存し，`install.sh` では外部dotfilesの取得に使用します．Codespaces の `GITHUB_TOKEN` では他のプライベートリポジトリを読めないため，Codespaces secrets に登録して使います|
|`EXTERNAL_DOTFILES_REPO`|外部dotfilesのリポジトリURL．指定されたdotfilesリポジトリの内容が優先されます|
|`DOTFILES_DIR`|`bootstrap.sh` のクローン先 (既定: `~/ghq/github.com/arumino-om/dotfiles`)|

## Layout

| パス | 内容 |
|---|---|
| `home/` | 全OS共通．`$HOME` に同じ相対パスでシンボリックリンクされる |
| `home-<os>/` | OS専用 (`darwin`, `linux`, ...) |
| `packages/git-repos.txt`, `packages-<os>/git-repos.txt` | git clone するリポジトリ (`<URL> <$HOMEからの相対パス>`) |
| `packages-darwin/Brewfile` | `brew bundle` でインストールするもの |

既存ファイルは `~/.dotfiles_backup/<日時>/` に退避されます．
`EXTERNAL_DOTFILES_REPO` を設定すると `external/` に clone し，同じ構成で上書き適用します (外部側が優先)．
