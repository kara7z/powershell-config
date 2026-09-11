# powershell-config

Backup of my Windows dev setup: PowerShell 7 + Neovim (LazyVim-based) + Starship + Windows Terminal + Yazi + Winget bundle.

Repo: https://github.com/kara7z/powershell-config.git
Local clone: `~/Documents/powershell-config`

## Contents

```
powershell-config/
  PowerShell/
    Microsoft.PowerShell_profile.ps1  -> ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
    powershell.config.json            -> ~/Documents/PowerShell/powershell.config.json
  nvim/                               -> %LOCALAPPDATA%/nvim/ (full init.lua + lua/config + lua/plugins)
    init.lua
    lua/config/
    lua/plugins/
    lazy-lock.json / lazyvim.json / ...
  starship.toml                       -> ~/.config/starship.toml
  windows-terminal/
    settings.json                     -> %LOCALAPPDATA%/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
  yazi/
    yazi.toml                         -> %APPDATA%/yazi/config/yazi.toml
  winget/
    winget-export.json                -> curated dev-tools list (PowerShell, Terminal, Git, Neovim, starship, zoxide, fzf, yazi, lazygit, oh-my-posh)
    setup.ps1                         -> fresh-machine installer (winget import)
  restore.ps1                         -> one-click restore script
```

Notes:
- `Microsoft.PowerShell_profile.ps1.bak` is intentionally NOT backed up (stale backup file).
- `nvim/.git/` is intentionally NOT backed up (was LazyVim starter git history).
- Also uses: starship, zoxide, fzf, yazi, PSReadLine (configured in profile, binaries not stored here).

## Restore (fresh machine)

```powershell
git clone https://github.com/kara7z/powershell-config.git ~/Documents/powershell-config
cd ~/Documents/powershell-config
Set-ExecutionPolicy Bypass -Scope Process -Force
.\winget\setup.ps1   # installs tools via winget import
.\restore.ps1        # restores configs
```

Or manually:
```powershell
Copy-Item .\PowerShell\* ~/Documents/PowerShell/ -Force
Copy-Item .\starship.toml ~/.config/starship.toml -Force
Copy-Item .\nvim\* $env:LOCALAPPDATA\nvim\ -Recurse -Force
Copy-Item .\windows-terminal\settings.json "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Force
Copy-Item .\yazi\yazi.toml "$env:APPDATA\yazi\config\yazi.toml" -Force
```

## Update backup

```powershell
Copy-Item ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1 .\PowerShell\ -Force
Copy-Item ~/Documents/PowerShell/powershell.config.json .\PowerShell\ -Force
Copy-Item ~/.config/starship.toml .\starship.toml -Force
Copy-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" .\windows-terminal\settings.json -Force
Copy-Item "$env:APPDATA\yazi\config\yazi.toml" .\yazi\yazi.toml -Force
Get-ChildItem $env:LOCALAPPDATA\nvim | Where-Object { $_.Name -ne '.git' } | ForEach-Object {
  Copy-Item $_.FullName .\nvim\$($_.Name) -Recurse -Force
}
git add -A; git commit -m "update backup"; git push
```

Last backup: 2026-09-11 (PowerShell 7.6.6, LazyVim + custom plugins: autosave, compiler, java-fix, stack, theme, etc.)
