if ((Test-Path "${env:ProgramFiles}\starship\bin\starship.exe") -or (Get-Command starship -CommandType Application -TotalCount 1 -ErrorAction SilentlyContinue)) { Invoke-Expression (&starship init powershell) # Report cwd to Windows Terminal (OSC 9;9) so Duplicate Tab/Pane # (Ctrl+D / Alt+Shift+D) opens in the same folder.
  # Must wrap AFTER starship init since it replaces prompt.
  $Global:__StarshipOrigPrompt = (Get-Item function:prompt).ScriptBlock
  function global:prompt {
    # Single string: invisible OSC 9;9 report + starship output untouched,
    # so the folder segment always renders.
    $loc = $executionContext.SessionState.Path.CurrentLocation
    $head = ""
    if ($loc.Provider.Name -eq "FileSystem") {
      $head = "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
    }
    $head + ((& $Global:__StarshipOrigPrompt) -join "")
  }
}
function yy {
    $tmp = New-TemporaryFile

    yazi @args --cwd-file="$tmp"

    if (Test-Path $tmp) {
        $cwd = Get-Content $tmp -Raw
        Remove-Item $tmp -Force

        if ($cwd) {
            Set-Location $cwd.Trim()
        }
    }
}

# --- FAST STARTUP: skip network/security checks (no style change) ---
$env:POWERSHELL_UPDATECHECK = 'Off'
$env:POWERSHELL_TELEMETRY_OPTOUT = '1'

# --- PSReadLine speed (behavior only, no colors changed) ---
# No Import-Module (autoloads) and NO Get-Module -ListAvailable (scans every
# module dir on disk). Skip prediction when output is redirected (scripts).
# -ErrorAction Stop + catch keeps startup silent in any host.
# No Get-Module -ListAvailable (scans every module dir on disk).
# PSReadLine ships with PS7 and autoloads when these cmdlets run.
# Line editing only matters in a real console: skip entirely when piped.
# -ErrorAction Stop + catch keeps startup silent in any host.
if (-not [Console]::IsOutputRedirected -and -not [Console]::IsInputRedirected) {
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle InlineView -HistoryNoDuplicates -BellStyle None -EditMode Windows -MaximumHistoryCount 10000 -HistorySearchCursorMovesToEnd -ErrorAction Stop
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction Stop
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction Stop
        Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete -ErrorAction Stop
    } catch {}
}

# --- FAST CD / NAVIGATION (pure PowerShell, instant) ---
function ..    { Set-Location .. }
function ...   { Set-Location ..\.. }
function ....  { Set-Location ..\..\.. }
function ..... { Set-Location ..\..\..\.. }
function back  { Pop-Location }
function mkcd([string]$d) { New-Item -ItemType Directory -Path $d -Force | Out-Null; Set-Location $d }
function up([int]$n = 1) { for ($i = 0; $i -lt $n; $i++) { Set-Location .. } }
function dev   { Set-Location "$HOME\Documents\Dev Projects" }
function nexa  { Set-Location "$HOME\Documents\Dev Projects\NexaBank" }
function proj([string]$name) {
    $root = "$HOME\Documents\Dev Projects"
    if (-not $name) { Set-Location $root; return }
    $hit = Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$name*" } | Select-Object -First 1
    if ($hit) { Set-Location $hit.FullName } else { Write-Host "no project match: $name" }
}
function ll { Get-ChildItem -Force @args | Format-Table Mode, LastWriteTime, Length, Name -AutoSize }
function la { Get-ChildItem -Force @args }
Set-Alias -Name l -Value Get-ChildItem -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name e -Value explorer -Scope Global -ErrorAction SilentlyContinue

# --- zoxide: smart cd that learns (replaces cd) ---
if (Get-Command zoxide -CommandType Application -TotalCount 1 -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
    # cdi = interactive cd with fzf. Add familiar z / zi names too:
    Set-Alias -Name z -Value __zoxide_z -Scope Global -Force -ErrorAction SilentlyContinue
    Set-Alias -Name zi -Value __zoxide_zi -Scope Global -Force -ErrorAction SilentlyContinue
}

# --- fzf: fuzzy find (skips MOTW/Zone checks by using raw paths) ---
if (Get-Command fzf -CommandType Application -TotalCount 1 -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_OPTS = '--height 40% --reverse --border --info=inline'
    function cdf([string]$q) {
        $d = Get-ChildItem -Directory -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName | fzf --query "$q" --select-1 --exit-0
        if ($d) { Set-Location $d }
    }
    function ff([string]$q) {
        $f = Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName | fzf --query "$q" --select-1 --exit-0
        if ($f) { $f }
    }
    function fh {
        $h = (Get-History | Sort-Object Id -Descending | ForEach-Object { $_.CommandLine } | Get-Unique) -join "`n" | fzf --tac --no-sort
        if ($h) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($h) }
    }
    # Ctrl+T = insert file path, Alt+C = cd to dir, Ctrl+R = history
    try {
        Set-PSReadLineKeyHandler -Chord 'Ctrl+t' -BriefDescription 'fzf file' -Description 'fzf file' -ScriptBlock {
            $line = $null; $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            $f = Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName | fzf --select-1 --exit-0
            if ($f) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert("`"$f`"") }
        }
        Set-PSReadLineKeyHandler -Chord 'Alt+c' -BriefDescription 'fzf cd' -Description 'fzf cd' -ScriptBlock {
            $d = Get-ChildItem -Directory -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName | fzf --select-1 --exit-0
            if ($d) { [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine(); [Microsoft.PowerShell.PSConsoleReadLine]::Insert("cd `"$d`""); [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() }
        }
        Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -BriefDescription 'fzf history' -Description 'fzf history' -ScriptBlock {
            $h = (Get-History | Sort-Object Id -Descending | ForEach-Object { $_.CommandLine } | Get-Unique) -join "`n" | fzf --tac --no-sort
            if ($h) { [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine(); [Microsoft.PowerShell.PSConsoleReadLine]::Insert($h) }
        }
    } catch {}
}

# --- winget: permanent fix (shadows broken 0-byte C:\Windows\System32\winget) ---
# Real winget lives at $env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe (v1.29.290).
# A function takes precedence over PATH lookup, so this permanently fixes `winget` in PS7.
function global:winget {
    $real = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if (Test-Path -LiteralPath $real) { & $real @args }
    else { & winget.exe @args }
}

# --- Remove slow file-exploration security checks (reversible) ---
# Unblock downloaded files once so Explorer/PowerShell stop re-checking Zone.Identifier:
function unblock-proj { Get-ChildItem "$HOME\Documents\Dev Projects" -Recurse -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue; Write-Host "Dev Projects unblocked." }
