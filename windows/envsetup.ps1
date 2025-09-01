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

  # Utility
  "GnuPG.GnuPG",
  "7zip.7zip",
  "Google.JapaneseIME"
)
winget install $packages


### Explorer configuration
Set-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -name "Hidden" -Value 1
Set-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -name "HideFileExt" -Value 0


### WSL configuration
wsl --install
wsl --install "Ubuntu-24.04"

