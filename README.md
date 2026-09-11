# My Windows Setup

This repo saves my terminal setup. If my PC breaks or I get a new PC,
I can get everything back with **2 commands**.

## What is inside?

| Folder | What it is (simple words) |
|---|---|
| `PowerShell/` | My PowerShell look and shortcuts (prompt, aliases, history search) |
| `nvim/` | My code editor settings (Neovim + LazyVim + my plugins) |
| `starship.toml` | The design of my prompt (the line where you type commands) |
| `windows-terminal/` | My Terminal window settings (font, colors, keys like Ctrl+C) |
| `yazi/` | My file manager settings (yazi, opened with the `yy` command) |
| `winget/` | The list of programs to install automatically |

Extra scripts:

| File | What it does |
|---|---|
| `install.ps1` | **Does everything at once** (install programs + font + settings). Use this one. |
| `restore.ps1` | Copies only the settings (use it if programs are already installed). |
| `winget/setup.ps1` | Installs only the programs. |

## New PC? Do this (2 steps)

**Step 1.** Download this repo:

```powershell
git clone https://github.com/kara7z/powershell-config.git ~/Documents/powershell-config
```

**Step 2.** Install everything:

```powershell
~/Documents/powershell-config/install.ps1
```

That is all. It installs the programs, the font, and all settings.

> If Windows blocks the script, run this first, then step 2 again:
>
> ```powershell
> Set-ExecutionPolicy Bypass -Scope Process -Force
> ```

## After the install

1. **Close the terminal and open it again.** Settings load only in a new window.
2. You should see a short prompt with the folder name, and icons should look normal.
3. Try these commands: `z` (smart folder jump), `yy` (file manager), `ff` (find a file).

## Problem: I see boxes □ instead of icons

The font is missing. Install it with this one command, then open a new terminal:

```powershell
oh-my-posh font install FiraCode
```

## Save my new changes (update the backup)

When you change a setting on your PC, copy it here and push:

```powershell
cd ~/Documents/powershell-config
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

## Notes

- The file `Microsoft.PowerShell_profile.ps1.bak` is an old copy, so it is not saved here.
- The folder `nvim/.git` is not saved here (it is just LazyVim update history).
- Programs installed: PowerShell 7, Windows Terminal, Git, Neovim, starship, zoxide, fzf, yazi, lazygit, oh-my-posh.
