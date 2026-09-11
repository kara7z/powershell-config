# Fresh-machine setup: install dev tools, then restore configs.
# Run AFTER cloning this repo:
#   Set-ExecutionPolicy Bypass -Scope Process -Force; .\winget\setup.ps1
#   .\restore.ps1
$ErrorActionPreference = 'Stop'

# NOTE: use the real winget, not the broken 0-byte C:\Windows\System32\winget shim
# (see Microsoft.PowerShell_profile.ps1 for the same workaround).
$Winget = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\winget.exe'
if (-not (Test-Path -LiteralPath $Winget)) { $Winget = 'winget.exe' }

$ExportJson = Join-Path $PSScriptRoot 'winget-export.json'
Write-Host "Installing packages from $ExportJson ..."
& $Winget import --import-file $ExportJson --accept-source-agreements --accept-package-agreements

Write-Host "Done. Next: run .\restore.ps1 from the repo root."
