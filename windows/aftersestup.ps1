$mise_installs = @(
  "python@3.12",
  "nodejs@lts"
)

$vscode_extensions = @(
  # Display languages
  "ms-ceintl.vscode-language-pack-ja",

  # Programming languages
  "ms-dotnettools.csharp",
  "ms-vscode.cpptools-extension-pack",
  "devsense.phptools-vscode",
  "ms-python.python",

  # Remotes
  "ms-vscode-remote.remote-wsl",
  "ms-vscode-remote.remote-containers",
  "ms-vscode-remote.remote-ssh",

  # Tools
  "ms-azuretools.vscode-docker",
  "github.copilot",

  # Themes
  "pkief.material-icon-theme"
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
    "SOFTERROR"   { Write-Host   "[$timestamp][ERROR]    $Message" -ForegroundColor Red }
    default   { Write-Host    "[$timestamp][$Level]   $Message" }
  }
}


### PowerShell version check
if ($PSVersionTable.PSVersion.Major -lt 7) {
  Write-Log "This script requires PowerShell 7 or higher." "SOFTERROR"
  Write-Log "Please run pwsh to use PowerShell 7" "SOFTERROR"
  exit 1
}


### Git configuration
Write-Log "Configuring Git..."
$gitEmail = git config --global user.email
$gitName = git config --global user.name
if ($gitEmail -and $gitName) {
  Write-Log "Git user information is already set." "INFO"
  Write-Log "    user.email: $gitEmail" "INFO"
  Write-Log "    user.name:  $gitName" "INFO"
} else {
  $gitEmail = Read-Host "E-mail address"
  $gitName = Read-Host "User name"

  git config --global user.email $gitEmail
  git config --global user.name $gitName

  Write-Log "Git configuration completed." "SUCCESS"
}


### mise installations
Write-Log "Installing the mise packages..."
foreach ($package in $mise_installs) {
  Write-Log "--> Installing $package..."
  mise install $package
  Write-Log "    Completed." "SUCCESS"
}
Write-Log "mise package installation completed." "SUCCESS"


### VSCode extensions
Write-Log "Installing VSCode extensions..."
$vscode_extensions | ForEach-Object { Write-Log " - $_" }
$vscode_extensions | ForEach-Object { code --install-extension $_ }
Write-Log "VSCode extensions installation completed." "SUCCESS"


### Copy profile scripts
Write-Log "Copying PowerShell profile..."
Copy-Item -Path (Join-Path $PSScriptRoot "PowerShell" "profile.ps1") -Destination $profile
Write-Log "Copied to $profile." "SUCCESS"
