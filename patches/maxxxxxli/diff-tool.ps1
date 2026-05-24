<#
.SYNOPSIS
  比对 MAXXXXXLI/workbuddy-cn-legal-skills 上游更新，生成差异报告

.DESCRIPTION
  将当前 patches/maxxxxxli/ 快照与 MAXXXXXLI 上游最新 commit 对比，
  输出变更详情，帮助判断是否需要同步。

  用法:
    .\patches\maxxxxxli\diff-tool.ps1              # 默认输出摘要
    .\patches\maxxxxxli\diff-tool.ps1 -Detailed     # 显示逐行 diff
    .\patches\maxxxxxli\diff-tool.ps1 -Update       # 比对后同步快照

.PARAMETER Detailed
  显示逐行差异（默认只显示文件级别摘要）

.PARAMETER Update
  比对后自动更新快照文件（谨慎使用，建议先审查差异）
#>

param(
    [switch]$Detailed,
    [switch]$Update
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PatchDir = $PSScriptRoot
$UpstreamUrl = 'https://github.com/MAXXXXXLI/workbuddy-cn-legal-skills.git'
$UpstreamDir = "$env:TEMP\max-upstream-check"

Write-Host '=== MAXXXXXLI 上游变更检查 ===' -ForegroundColor Cyan
Write-Host ""

# ---- [1] 拉取最新上游 ----
Write-Host '[1/4] 获取上游仓库...' -ForegroundColor Yellow
if (Test-Path "$UpstreamDir\.git") {
    Push-Location $UpstreamDir
    git pull --ff-only 2>&1 | Out-Null
    Pop-Location
    Write-Host '  上游已更新到最新'
} else {
    if (Test-Path $UpstreamDir) { Remove-Item -Recurse -Force $UpstreamDir }
    Push-Location $env:TEMP
    git clone --depth 1 $UpstreamUrl max-upstream-check 2>$null
    Pop-Location
    Write-Host '  上游已克隆到临时目录'
}

Push-Location $UpstreamDir
$latestCommit = git log -1 --format='%H'
$latestDate = git log -1 --format='%ci'
Pop-Location
Write-Host "  最新 commit: $($latestCommit.Substring(0,12))"
Write-Host "  提交时间: $latestDate"
Write-Host ""

# ---- [2] 提取上游的最新语境文件 ----
Write-Host '[2/4] 提取上游语境文件...' -ForegroundColor Yellow

$extractDir = "$env:TEMP\max-upstream-extract"
if (Test-Path $extractDir) { Remove-Item -Recurse -Force $extractDir }
$null = New-Item -ItemType Directory -Force $extractDir

# Extract china-legal-context.md from first ZIP
$zips = Get-ChildItem "$UpstreamDir\可导入技能包" -Filter *.zip
if ($zips.Count -eq 0) { Write-Host '  [错误] 上游 ZIP 文件不存在'; exit 1 }

$firstZip = $zips | Select-Object -First 1
$td1 = "$extractDir\_global"
Expand-Archive $firstZip.FullName -DestinationPath $td1 -Force
$globalCtx = "$td1\references\china-legal-context.md"
if (Test-Path $globalCtx) { Copy-Item $globalCtx "$extractDir\china-legal-context.md" }
Remove-Item -Recurse -Force $td1 -ErrorAction SilentlyContinue

# Extract per-module china-context.md
$modules = @{}
foreach ($zip in $zips) {
    $module = ($zip.BaseName -split '-')[0]
    if ($modules.ContainsKey($module)) { continue }
    $modules[$module] = $true
    
    $td = "$extractDir\_mod"
    Expand-Archive $zip.FullName -DestinationPath $td -Force
    $ctx = "$td\references\china-context.md"
    if (Test-Path $ctx) {
        $safeName = $module -replace '[\\/:*?"<>|]', '_'
        Copy-Item $ctx "$extractDir\china-context-$safeName.md"
    }
    Remove-Item -Recurse -Force $td -ErrorAction SilentlyContinue
}

Write-Host "  已提取 $(@(Get-ChildItem "$extractDir\*.md").Count) 个语境文件"
Write-Host ""

# ---- [3] 逐项比对 ----
Write-Host '[3/4] 逐项比对...' -ForegroundColor Yellow

$changed = @()
$unchanged = @()
$new = @()

# Compare china-legal-context.md
$upGlobal = "$extractDir\china-legal-context.md"
$patchGlobal = "$PatchDir\references\china-legal-context.md"
if (Test-Path $upGlobal) {
    $upHash = (Get-FileHash $upGlobal -Algorithm SHA256).Hash
    $paHash = (Get-FileHash $patchGlobal -Algorithm SHA256).Hash
    if ($upHash -ne $paHash) {
        Write-Host '  [Δ] china-legal-context.md（全局法源指引）' -ForegroundColor Yellow
        $changed += 'china-legal-context.md'
        if ($Detailed) {
            $diff = & git diff --no-index "$patchGlobal" "$upGlobal" 2>&1
            $diffLines = $diff -split "`n"
            $shown = 0
            foreach ($dl in $diffLines) {
                if ($shown -ge 30) { break }
                if ($dl -match '^[+-]' -and $dl -notmatch '^\+\+\+|^---|^@@') {
                    Write-Host "    $dl" -ForegroundColor DarkGray
                    $shown++
                }
            }
        }
    } else {
        Write-Host '  [✓] china-legal-context.md（全局法源指引）' -ForegroundColor Green
        $unchanged += 'china-legal-context.md'
    }
}

# Compare per-module china-context files
Get-ChildItem "$PatchDir\references\china-context-*.md" | ForEach-Object {
    $fileName = $_.Name
    $upFile = "$extractDir\$fileName"
    if (Test-Path $upFile) {
        $upHash = (Get-FileHash $upFile -Algorithm SHA256).Hash
        $paHash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
        if ($upHash -ne $paHash) {
            Write-Host "  [Δ] $fileName" -ForegroundColor Yellow
            $changed += $fileName
        } else {
            Write-Host "  [✓] $fileName" -ForegroundColor Green
            $unchanged += $fileName
        }
    } else {
        Write-Host "  [?] $fileName（上游已删除）" -ForegroundColor Red
        $changed += $fileName
    }
}

# Check for new modules in upstream
$upModules = $modules.Keys | ForEach-Object { $safe = $_ -replace '[\\/:*?"<>|]', '_'; "china-context-$safe.md" }
foreach ($upFile in $upModules) {
    $patchFile = "$PatchDir\references\$upFile"
    if (-not (Test-Path $patchFile)) {
        Write-Host "  [+] $upFile（新增模块）" -ForegroundColor Cyan
        $new += $upFile
    }
}

# Compare NOTICE
$upNotice = "$UpstreamDir\NOTICE"
$patchNotice = "$PatchDir\metadata\NOTICE"
if (Test-Path $upNotice) {
    $upHash = (Get-FileHash $upNotice -Algorithm SHA256).Hash
    $paHash = (Get-FileHash $patchNotice -Algorithm SHA256).Hash
    if ($upHash -ne $paHash) {
        Write-Host '  [Δ] NOTICE' -ForegroundColor Yellow
        $changed += 'NOTICE'
    } else { Write-Host '  [✓] NOTICE' -ForegroundColor Green }
}

# Compare skill count
$upCount = $zips.Count
$patchCsv = Import-Csv "$PatchDir\skills-index\skills-manifest.csv"
$patchCount = $patchCsv.Count
if ($upCount -ne $patchCount) {
    Write-Host "  [Δ] 技能数量: 上游=$upCount, 快照=$patchCount" -ForegroundColor Yellow
} else {
    Write-Host "  [✓] 技能数量: $upCount（一致）" -ForegroundColor Green
}

# ---- [4] 汇总 ----
Write-Host "`n[4/4] 汇总" -ForegroundColor Yellow
Write-Host "  总检查项: $($changed.Count + $unchanged.Count + $new.Count)"
Write-Host "  已变更: $($changed.Count)" -ForegroundColor Yellow
Write-Host "  未变化: $($unchanged.Count)" -ForegroundColor Green
Write-Host "  新增: $($new.Count)" -ForegroundColor Cyan

if ($changed.Count -gt 0 -or $new.Count -gt 0) {
    Write-Host "`n  ⚠ 上游有更新，建议审查后同步" -ForegroundColor Yellow
    Write-Host "  审查后运行: .\patches\maxxxxxli\diff-tool.ps1 -Update" -ForegroundColor DarkGray
}

# ---- 可选：更新快照 ----
if ($Update -and ($changed.Count -gt 0 -or $new.Count -gt 0)) {
    Write-Host "`n[更新快照]..." -ForegroundColor Yellow
    
    # Update china-legal-context
    if (Test-Path $upGlobal) {
        Copy-Item $upGlobal $patchGlobal -Force
        Write-Host "  已更新: china-legal-context.md" -ForegroundColor Green
    }
    
    # Update per-module contexts
    Get-ChildItem "$PatchDir\references\china-context-*.md" | ForEach-Object {
        $upFile = "$extractDir\$($_.Name)"
        if (Test-Path $upFile) {
            Copy-Item $upFile $_.FullName -Force
            Write-Host "  已更新: $($_.Name)" -ForegroundColor Green
        }
    }
    
    # Add new module contexts
    foreach ($nf in $new) {
        $src = "$extractDir\$nf"
        $dst = "$PatchDir\references\$nf"
        if (Test-Path $src) {
            Copy-Item $src $dst -Force
            Write-Host "  已新增: $nf" -ForegroundColor Green
        }
    }
    
    # Update NOTICE
    if (Test-Path $upNotice) {
        Copy-Item $upNotice $patchNotice -Force
        Write-Host "  已更新: NOTICE" -ForegroundColor Green
    }
    
    # Update skills manifest
    if ($upCount -ne $patchCount) {
        Write-Host "  [!] 技能数量已变化（$patchCount → $upCount），请手动更新 skills-manifest.csv" -ForegroundColor Yellow
    }
    
    Write-Host "  快照已同步。请在 CHANGELOG.md 中记录本次变更。" -ForegroundColor Green
}

# 清理临时目录
Remove-Item -Recurse -Force $UpstreamDir -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $extractDir -ErrorAction SilentlyContinue
Write-Host "`n清理完成。" -ForegroundColor Green

