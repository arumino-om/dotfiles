# dotfiles
自分の設定ファイルなどを放り込むリポジトリ。環境構築用のスクリプトもあります。

## ディレクトリ
OS毎にディレクトリを分けています。
- `windows` ... Windows 固有の設定ファイル
- `ubuntu` ... Ubuntu/WSL 固有の設定ファイル

## Windowsでの使い方
1. `windows/bootstrap.bat` を実行します
2. 再起動します（WSLインストールが実行されなかった場合は，ターミナルだけ再起動でもOK）
3. `windows/aftersetup.ps1` を実行します