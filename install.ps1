# One-command setup for a new PC: installs tools + font + restores all configs.
#
#   1. git clone https://github.com/kara7z/powershell-config.git ~/Documents/powershell-config
#   2. ~/Documents/powershell-config/install.ps1
#
# If Windows blocks the script, run this first (one time):
#   Set-ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = 'Stop'
$RepoRoot = $PSScriptRoot

# 1/3 - Tools: PowerShell 7, Terminal, Git, Neovim, starship, zoxide, fzf, yazi, lazygit
Write-Host '[1/3] Installing tools ...'
& (Join-Path $RepoRoot 'winget\setup.ps1')

# 2/3 - Font: FiraCode Nerd Font (icons in Terminal + Neovim). Skip if already there.
Write-Host '[2/3] Checking font ...'
$FontFound = Get-ChildItem 'C:\Windows\Fonts\*Fira*' -ErrorAction SilentlyContinue `
  -or (Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts\*Fira*') -ErrorAction SilentlyContinue)
if (-not $FontFound) {
  Write-Host 'Installing FiraCode Nerd Font ...'
  oh-my-posh font install FiraCode
} else {
  Write-Host 'FiraCode already installed, skipping.'
}

# 3/3 - Configs: PowerShell profile, starship, Neovim, Terminal, Yazi
Write-Host '[3/3] Restoring configs ...'
& (Join-Path $RepoRoot 'restore.ps1')
