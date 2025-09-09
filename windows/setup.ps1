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
  "ajeetdsouza.zoxide",
  "x-motemen.ghq",
  "7zip.7zip",
  "Google.JapaneseIME",

  # Social
  "Discord.Discord",
  "Microsoft.Teams"
)

$registry_configs = @(
  ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden", 1), # 隠しファイル表示
  ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt", 0), # 拡張子表示
  ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "SeparateProcess", 1), # 別プロセスで起動
  ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "TaskbarAl", 0), # タスクバーを左寄せ

  ("HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem", "LongPathsEnabled", 1), # 255文字以上のパスを有効化
  ("HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout", "Scancode Map", ([byte[]](
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x1D,0x00,0x3A,0x00,0x00,0x00,0x00,0x00
  ))) # Caps Lock を Ctrl にする
)

$wsl_distros = @(
  "Ubuntu-24.04"
)

function Write-Log {
  param(
    [string]$Message,
    [string]$Level = "INFO"
  )
  $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  switch ($Level) {
    "INFO"    { Write-Host    "[$timestamp][INFO]     $Message" -ForegroundColor Cyan }
    "SUCCESS" { Write-Host    "[$timestamp][SUCCESS]  $Message" -ForegroundColor Green }
    "WARN"    { Write-Warning "[$timestamp][WARN]     $Message" }
    "ERROR"   { Write-Error   "[$timestamp][ERROR]    $Message" }
    default   { Write-Host    "[$timestamp][$Level]   $Message" }
  }
}

### Package installations
Write-Log "Installing the following packages..."
$packages | ForEach-Object { Write-Log " - $_" }
winget install $packages --accept-source-agreements --accept-package-agreements
Write-Log "Package installation completed." "SUCCESS"


### Registry tweaks
Write-Log "Changing registry settings..."
foreach ($config in $registry_configs) {
  Write-Log "--> Changing $($config[1]) in $($config[0])..."
  if ($config[2] -is [byte[]]) {
    Set-ItemProperty -Path $config[0] -Name $config[1] -Value $config[2] -Type Binary
  } else {
    Set-ItemProperty -Path $config[0] -Name $config[1] -Value $config[2]
  }
}
Write-Log "Registry settings changed successfully." "SUCCESS"


### WSL configuration
Write-Log "Installing WSL..."
$wslDistros = (wsl --list --quiet) -split "`n"
foreach ($distro in $wsl_distros) {
  Write-Log "--> Installing $distro..."
  if ($wslDistros -notcontains $distro) {
    wsl --install $distro --no-launch
    Write-Log "    Completed." "SUCCESS"
  } else {
    Write-Log "    Already installed." "INFO"
  }
}
