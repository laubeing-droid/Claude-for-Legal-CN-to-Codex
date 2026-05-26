<#
.SYNOPSIS
  Environment consistency checker for laubeing-droid repos.
  Runs BEFORE install.ps1 to validate local environment matches dev environment.
  Blocks install on critical mismatches; warns on potential issues.
#>

param([switch]$Quick, [switch]$Json, [switch]$SkipNetwork)

$ErrorActionPreference = 'Continue'
$script:Issues = @()
$script:Crit = 0
$script:Warn = 0

function Add-Issue($Level, $Category, $Message, $Fix) {
    $script:Issues += [PSCustomObject]@{ Level = $Level; Category = $Category; Message = $Message; Fix = $Fix }
    if ($Level -eq 'CRITICAL') { $script:Crit++ } elseif ($Level -eq 'WARNING') { $script:Warn++ }
    if (-not $Json) {
        $icon = @{CRITICAL='[X]'; WARNING='[!]'; OK='[V]'}[$Level]
        $color = @{CRITICAL='Red'; WARNING='Yellow'; OK='Green'}[$Level]
        Write-Host "  $icon [$Category] $Message" -ForegroundColor $color
        if ($Fix) { Write-Host "       fix: $Fix" -ForegroundColor DarkGray }
    }
}

Write-Host ""
Write-Host "=== Environment Consistency Check ===" -ForegroundColor Cyan
Write-Host "  Target: laubeing-droid dev environment parity" -ForegroundColor DarkGray
Write-Host ""

# [1/8] OS + Shell
Write-Host "[1/8] OS & Shell" -ForegroundColor Yellow
$psVer = $PSVersionTable.PSVersion
if ($psVer.Major -ge 5 -and $psVer.Minor -ge 1) {
    Add-Issue 'OK' 'Shell' "PowerShell $psVer (req >=5.1)" ''
} else {
    Add-Issue 'CRITICAL' 'Shell' "PowerShell $psVer too old" "winget install Microsoft.PowerShell"
}
$isWin = $PSVersionTable.PSEdition -eq 'Desktop' -or $env:OS -like '*Windows*'
if (-not $isWin) {
    try { bash --version 2>$null | Out-Null; Add-Issue 'OK' 'Shell' "bash available" '' }
    catch { Add-Issue 'CRITICAL' 'Shell' "bash not found" "install bash >= 4.0" }
}

# [2/8] Python
Write-Host "[2/8] Python Runtime" -ForegroundColor Yellow
$pyCmd = $null; $pyVer = $null
foreach ($c in @('python3','python')) {
    try { $vo = & $c --version 2>&1; if ($vo -match '(\d+)\.(\d+)') { $pyCmd = $c; $pyVer = [Version]("$($matches[1]).$($matches[2])"); break } } catch {}
}
if (-not $pyCmd) {
    Add-Issue 'CRITICAL' 'Python' "Python not in PATH" "winget install Python.Python.3.12"
} elseif ($pyVer.Major -eq 3 -and $pyVer.Minor -ge 10) {
    Add-Issue 'OK' 'Python' "Python $pyVer (>=3.10 required by mcp SDK)" ''
} elseif ($pyVer.Minor -ge 8) {
    Add-Issue 'WARNING' 'Python' "Python $pyVer 鈥?mcp SDK requires >=3.10" "winget install Python.Python.3.12"
} else {
    Add-Issue 'CRITICAL' 'Python' "Python $pyVer incompatible" "winget install Python.Python.3.12"
}
if ($pyCmd) {
    try { & $pyCmd -m pip --version 2>&1 | Out-Null; Add-Issue 'OK' 'Python' "pip ready" '' }
    catch { Add-Issue 'CRITICAL' 'Python' "pip broken" "$pyCmd -m ensurepip --upgrade" }
}

# [3/8] Python packages (quick inline check)
if (-not $Quick) {
    Write-Host "[3/8] Python Key Packages" -ForegroundColor Yellow
    if ($pyCmd) {
        # Write a temp Python script to avoid string escaping issues
        $tmpPy = [System.IO.Path]::GetTempFileName() + '.py'
        @"
import importlib.metadata, json, sys
r = {}
pkglist = [("mcp","1.0.0"),("httpx","0.27.0"),("pydantic","2.0.0")]
for name,minver in pkglist:
    try:
        v = importlib.metadata.version(name)
        r[name] = {"installed":v,"required":minver,"ok":True}
    except:
        r[name] = {"installed":None,"required":minver,"ok":False}
try:
    import pydantic
    if hasattr(pydantic,"VERSION") and str(pydantic.VERSION).startswith("1"):
        r["pydantic"] = {"installed":str(pydantic.VERSION),"required":"2.0.0","ok":False,"err":"pydantic v1 detected"}
except: pass
print(json.dumps(r))
"@ | Out-File -FilePath $tmpPy -Encoding UTF8
        try {
            $pj = & $pyCmd $tmpPy 2>&1 | ConvertFrom-Json
            foreach ($pn in @('mcp','httpx','pydantic')) {
                $inf = $pj.$pn
                if ($inf.ok) { Add-Issue 'OK' 'Pkg' "$pn==$($inf.installed) (req>=$($inf.required))" '' }
                elseif ($inf.installed) {
                    if ($inf.err) { Add-Issue 'CRITICAL' 'Pkg' $inf.err "pip uninstall pydantic -y; pip install pydantic>=2.0.0" }
                    else { Add-Issue 'WARNING' 'Pkg' "$pn==$($inf.installed) need>=$($inf.required)" "pip install --upgrade $pn" }
                }
                else { Add-Issue 'WARNING' 'Pkg' "$pn not installed" "pip install $pn>=$($inf.required)" }
            }
        } catch { Add-Issue 'WARNING' 'Pkg' "Cannot inspect (will auto-install)" "pip list | findstr mcp httpx pydantic" }
        Remove-Item $tmpPy -Force -ErrorAction SilentlyContinue
    }
}

# [4/8] Node.js
Write-Host "[4/8] Node.js Runtime" -ForegroundColor Yellow
try {
    $nv = & node --version 2>&1
    if ($nv -match 'v?(\d+)' -and [int]$matches[1] -ge 18) { Add-Issue 'OK' 'Node.js' "Node.js $nv" '' }
    elseif ($nv) { Add-Issue 'WARNING' 'Node.js' "Node.js $nv (<18)" "winget install OpenJS.NodeJS.LTS" }
    else { throw }
} catch { Add-Issue 'WARNING' 'Node.js' "Node.js not found" "winget install OpenJS.NodeJS.LTS" }

# [5/8] Git
Write-Host "[5/8] Git" -ForegroundColor Yellow
try { $gv = & git --version 2>&1; Add-Issue 'OK' 'Git' "$gv" '' }
catch { Add-Issue 'CRITICAL' 'Git' "Git not found" "winget install Git.Git" }

# [6/8] Disk
Write-Host "[6/8] Disk Space" -ForegroundColor Yellow
try {
    $d = Get-PSDrive (Get-Location).Drive.Name
    $f = [math]::Round($d.Free/1GB,1)
    if ($f -lt 1) { Add-Issue 'CRITICAL' 'Disk' "$f GB free (<1GB)" "free disk space" }
    elseif ($f -lt 5) { Add-Issue 'WARNING' 'Disk' "$f GB free (<5GB)" '' }
    else { Add-Issue 'OK' 'Disk' "$f GB free" '' }
} catch { Add-Issue 'WARNING' 'Disk' "Cannot check" '' }

# [7/8] Network
if (-not $SkipNetwork) {
    Write-Host "[7/8] Network" -ForegroundColor Yellow
    $tgts = @(
        @{n='GitHub';u='https://github.com';c=$true},
        @{n='PyPI';u='https://pypi.org';c=$true},
        @{n='npm';u='https://registry.npmjs.org';c=$false},
        @{n='FLK';u='https://flk.npc.gov.cn';c=$false},
        @{n='RMFY';u='https://rmfyalk.court.gov.cn';c=$false}
    )
    foreach ($t in $tgts) {
        try { $null = Invoke-WebRequest -Uri $t.u -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            Add-Issue 'OK' 'Network' "$($t.n) reachable" '' }
        catch {
            if ($t.c) { Add-Issue 'CRITICAL' 'Network' "$($t.n) unreachable" "check network/proxy" }
            else { Add-Issue 'WARNING' 'Network' "$($t.n) unreachable" '' }
        }
    }
}

# [8/8] Platforms
Write-Host "[8/8] AI Platforms" -ForegroundColor Yellow
$pfs = @{
    'Codex Desktop'="$env:USERPROFILE\.codex"
    'Claude Code'="$env:USERPROFILE\.claude\settings.json"
    'WorkBuddy'="$env:USERPROFILE\.workbuddy"
    'Trae'="$env:USERPROFILE\.trae"
}
foreach ($k in $pfs.Keys) {
    if (Test-Path $pfs[$k]) { Add-Issue 'OK' 'Platform' "$k installed" '' }
    else { Add-Issue 'WARNING' 'Platform' "$k not installed" '' }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($Json) {
    @{status=if($script:Crit -eq 0){'pass'}else{'fail'};critical=$script:Crit;warnings=$script:Warn;issues=$script:Issues;timestamp=(Get-Date -Format 'o')} | ConvertTo-Json -Depth 4
} else {
    Write-Host "  CRITICAL: $script:Crit  |  WARNINGS: $script:Warn" -ForegroundColor Cyan
    if ($script:Crit -gt 0) { Write-Host "  BLOCKED 鈥?fix CRITICAL items above" -ForegroundColor Red; Write-Host "  Re-run: .\env-check.ps1" -ForegroundColor DarkGray }
    elseif ($script:Warn -gt 0) { Write-Host "  PASS with warnings 鈥?limited functionality possible" -ForegroundColor Yellow }
    else { Write-Host "  ALL CLEAR 鈥?safe to install" -ForegroundColor Green }
    Write-Host "========================================" -ForegroundColor Cyan
}
if ($script:Crit -gt 0) { exit 1 } else { exit 0 }