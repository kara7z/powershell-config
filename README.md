# powershell-config

Backup of my Windows dev setup: PowerShell 7 + Neovim (LazyVim-based) + Starship.

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
  restore.ps1                         -> one-click restore script
```

Notes:
- `Microsoft.PowerShell_profile.ps1.bak` is intentionally NOT backed up (stale backup file).
- `nvim/.git/` is intentionally NOT backed up (was LazyVim starter git history).
- Also uses: starship, zoxide, fzf, yazi, PSReadLine (configured in profile, binaries not stored here).

## Restore (fresh machine)

```powershell
git clone https://github.com/kara7z/powershell-config.git ~/Documents/powershell-config
.\Documents\powershell-config\restore.ps1
```

Or manually:
```powershell
Copy-Item .\PowerShell\* ~/Documents/PowerShell/ -Force
Copy-Item .\starship.toml ~/.config/starship.toml -Force
Copy-Item .\nvim\* $env:LOCALAPPDATA\nvim\ -Recurse -Force
```

## Update backup

```powershell
Copy-Item ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1 .\PowerShell\ -Force
Copy-Item ~/Documents/PowerShell/powershell.config.json .\PowerShell\ -Force
Copy-Item ~/.config/starship.toml .\starship.toml -Force
Get-ChildItem $env:LOCALAPPDATA\nvim | Where-Object { $_.Name -ne '.git' } | ForEach-Object {
  Copy-Item $_.FullName .\nvim\$($_.Name) -Recurse -Force
}
git add -A; git commit -m "update backup"; git push
```

Last backup: 2026-09-11 (PowerShell 7.6.6, LazyVim + custom plugins: autosave, compiler, java-fix, stack, theme, etc.)
