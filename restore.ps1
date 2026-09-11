# Restore PowerShell + Neovim + Starship configs from this repo
# Run: .\restore.ps1
$ErrorActionPreference = 'Stop'
$RepoRoot = $PSScriptRoot

# 1. PowerShell 7 profile
$PsDest = Join-Path $HOME 'Documents\PowerShell'
New-Item -ItemType Directory -Path $PsDest -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $RepoRoot 'PowerShell\Microsoft.PowerShell_profile.ps1') -Destination (Join-Path $PsDest 'Microsoft.PowerShell_profile.ps1') -Force
Copy-Item -LiteralPath (Join-Path $RepoRoot 'PowerShell\powershell.config.json') -Destination (Join-Path $PsDest 'powershell.config.json') -Force
Write-Host "Restored PowerShell -> $PsDest"

# 2. Starship
$StarDest = Join-Path $HOME '.config\starship.toml'
New-Item -ItemType Directory -Path (Split-Path $StarDest) -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $RepoRoot 'starship.toml') -Destination $StarDest -Force
Write-Host "Restored starship -> $StarDest"

# 3. Neovim
$NvimDest = Join-Path $env:LOCALAPPDATA 'nvim'
New-Item -ItemType Directory -Path $NvimDest -Force | Out-Null
Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'nvim') -Force | ForEach-Object {
  Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $NvimDest $_.Name) -Recurse -Force
}
Write-Host "Restored nvim -> $NvimDest"

Write-Host "Done. Restart PowerShell / Neovim."
