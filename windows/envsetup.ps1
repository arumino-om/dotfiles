### Package installations
$packages = @(
  # IDE & Editor
  "Microsoft.VisualStudioCode",
  "Microsoft.VisualStudio.2022.Community",
  "Neovim.Neovim",

  # Terminal environment
  "Microsoft.PowerShell",
  "Starship.Starship",
  
  # Programming tools
  "jdx.mise",
  "Git.Git",
  "Postman.Postman",
  "Docker.DockerDesktop",

  # Utility
  "GnuPG.GnuPG",
  "7zip.7zip",
  "Google.JapaneseIME"

  # Social
  "Discord.Discord",
  "Microsoft.Teams"
)
Write-Host "以下のパッケージをインストールします..."
$packages | ForEach-Object { Write-Host "- $_" }
winget install $packages --accept-source-agreements --accept-package-agreements
Write-Host "パッケージのインストールが完了しました。"


### Registry tweaks
Write-Host "レジストリの設定を変更しています..."
$registry_configs = @(
  ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden", 1), # 隠しファイル表示
  ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt", 0), # 拡張子表示
  ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "SeparateProcess", 1), # 別プロセスで起動
  ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "TaskbarAl", 0), # タスクバーを左寄せ

  ("HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem", "LongPathsEnabled", 1), # 255文字以上のパスを有効化
  ("HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout", "Scancode Map", ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x1D,0x00,0x3A,0x00,0x00,0x00,0x00,0x00))) # Caps Lock を Ctrl
)

# Apply Registry settings
foreach ($config in $registry_configs) {
  if ($config[2] -is [byte[]]) {
    Set-ItemProperty -Path $config[0] -Name $config[1] -Value $config[2] -Type Binary
  } else {
    Set-ItemProperty -Path $config[0] -Name $config[1] -Value $config[2]
  }
}

Write-Host "レジストリの設定変更が完了しました。"


### WSL configuration
Write-Host "WSLをインストールしています..."
wsl --install "Ubuntu-24.04"
Write-Host "WSLのインストールが完了しました。"


### Git configuration
Write-Host "Gitの設定を行います..."
$gitEmail = Read-Host "E-mailアドレスを入力してください"
$gitName = Read-Host "ユーザー名を入力してください"

git config --global user.email $gitEmail
git config --global user.name $gitName

Write-Host "Gitの設定が完了しました。"


### Copy profile scripts
Write-Host "PowerShellプロファイルをコピーしています..."
Copy-Item -Path (Join-Path $PSScriptRoot "profile.ps1") -Destination $profile -Force
Write-Host "$profile にコピーしました。"