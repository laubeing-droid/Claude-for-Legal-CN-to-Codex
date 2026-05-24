<#
.SYNOPSIS
  比对 zhou210712/claude-for-legal-ZH 上游更新，生成差异报告

.DESCRIPTION
  将当前 patches/zhou210712/ 快照与 zhou210712 上游最新 commit 对比，
  输出变更详情，帮助判断是否需要同步。

  用法:
    .\patches\zhou210712\diff-tool.ps1              # 默认输出摘要
    .\patches\zhou210712\diff-tool.ps1 -Detailed     # 输出逐行 diff
    .\patches\zhou210712\diff-tool.ps1 -Update       # 比对后同步快照

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
$UpstreamUrl = 'https://github.com/zhou210712/claude-for-legal-ZH.git'
$UpstreamDir = "$env:TEMP\zhou-upstream-check"

Write-Host '=== zhou210712 上游变更检查 ===' -ForegroundColor Cyan
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
    git clone --depth 1 $UpstreamUrl zhou-upstream-check 2>$null
    Pop-Location
    Write-Host '  上游已克隆到临时目录'
}

# 获取最新 commit
Push-Location $UpstreamDir
$latestCommit = git log -1 --format='%H'
$latestDate = git log -1 --format='%ci'
Pop-Location
Write-Host "  最新 commit: $($latestCommit.Substring(0,12))"
Write-Host "  提交时间: $latestDate"
Write-Host ""

# ---- [2] 定义检查清单 ----
Write-Host '[2/4] 逐项比对...' -ForegroundColor Yellow

$checklist = @(
    @{ Category='引用文件'; Name='contract-law-core.md';          Upstream='commercial-legal/references/contract-law-core.md';       Patch='references/contract-law-core.md' },
    @{ Category='引用文件'; Name='civil-procedure-core.md';       Upstream='litigation-legal/references/civil-procedure-core.md';    Patch='references/civil-procedure-core.md' },
    @{ Category='引用文件'; Name='evidence-rules-core.md';        Upstream='litigation-legal/references/evidence-rules-core.md';     Patch='references/evidence-rules-core.md' },
    @{ Category='引用文件'; Name='enforcement-core.md';            Upstream='litigation-legal/references/enforcement-core.md';       Patch='references/enforcement-core.md' },
    @{ Category='引用文件'; Name='labor-core-rules.md';           Upstream='employment-legal/references/labor-core-rules.md';       Patch='references/labor-core-rules.md' },
    @{ Category='引用文件'; Name='company-law-2024-core.md';      Upstream='corporate-legal/references/company-law-2024-core.md';   Patch='references/company-law-2024-core.md' },
    @{ Category='引用文件'; Name='ip-core-rules.md';              Upstream='ip-legal/references/ip-core-rules.md';                  Patch='references/ip-core-rules.md' },
    @{ Category='引用文件'; Name='admin-law-core.md';             Upstream='regulatory-legal/references/admin-law-core.md';         Patch='references/admin-law-core.md' },
    @{ Category='引用文件'; Name='pipil-core-provisions.md';      Upstream='privacy-legal/references/pipil-core-provisions.md';     Patch='references/pipil-core-provisions.md' },
    @{ Category='引用文件'; Name='ai-governance-core.md';         Upstream='ai-governance-legal/references/ai-governance-core.md';  Patch='references/ai-governance-core.md' },
    @{ Category='引用文件'; Name='currency-watch.md (中国版)';     Upstream='ai-governance-legal/references/currency-watch.md';     Patch='references/currency-watch.md' },
    @{ Category='CLAUDE.md'; Name='commercial-legal';             Upstream='commercial-legal/CLAUDE.md';                            Patch='skills/commercial-legal.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='litigation-legal';             Upstream='litigation-legal/CLAUDE.md';                            Patch='skills/litigation-legal.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='employment-legal';             Upstream='employment-legal/CLAUDE.md';                            Patch='skills/employment-legal.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='privacy-legal';                Upstream='privacy-legal/CLAUDE.md';                               Patch='skills/privacy-legal.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='corporate-legal';              Upstream='corporate-legal/CLAUDE.md';                             Patch='skills/corporate-legal.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='ip-legal';                     Upstream='ip-legal/CLAUDE.md';                                    Patch='skills/ip-legal.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='product-legal';                Upstream='product-legal/CLAUDE.md';                               Patch='skills/product-legal.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='regulatory-legal';             Upstream='regulatory-legal/CLAUDE.md';                            Patch='skills/regulatory-legal.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='ai-governance-legal';          Upstream='ai-governance-legal/CLAUDE.md';                         Patch='skills/ai-governance-legal.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='law-student';                  Upstream='law-student/CLAUDE.md';                                 Patch='skills/law-student.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='legal-clinic';                 Upstream='legal-clinic/CLAUDE.md';                                Patch='skills/legal-clinic.CLAUDE.md' },
    @{ Category='CLAUDE.md'; Name='legal-builder-hub';            Upstream='legal-builder-hub/CLAUDE.md';                           Patch='skills/legal-builder-hub.CLAUDE.md' }
)

$changed = @()
$unchanged = @()
$new = @()

foreach ($item in $checklist) {
    $upstreamFile = "$UpstreamDir/$($item.Upstream)"
    $patchFile = "$PatchDir/$($item.Patch)"

    if (-not (Test-Path $upstreamFile)) {
        Write-Host "  [!] 上游文件已不存在: $($item.Name)" -ForegroundColor Red
        continue
    }

    if (-not (Test-Path $patchFile)) {
        Write-Host "  [+] 新增文件（快照中没有）: $($item.Name)" -ForegroundColor Yellow
        $new += $item
        continue
    }

    $upstreamHash = (Get-FileHash $upstreamFile -Algorithm SHA256).Hash
    $patchHash = (Get-FileHash $patchFile -Algorithm SHA256).Hash

    if ($upstreamHash -ne $patchHash) {
        Write-Host "  [Δ] 已变更: $($item.Name)" -ForegroundColor Yellow
        $changed += $item

        if ($Detailed) {
            $diff = & git diff --no-index "$patchFile" "$upstreamFile" 2>&1
            # 只显示前 30 行差异
            $diffLines = $diff -split "`n"
            $shown = 0
            foreach ($dl in $diffLines) {
                if ($shown -ge 30) { Write-Host '    ...(更多差异)' -ForegroundColor DarkGray; break }
                Write-Host "    $dl" -ForegroundColor DarkGray
                $shown++
            }
        }
    } else {
        Write-Host "  [✓] 未变化: $($item.Name)" -ForegroundColor Green
        $unchanged += $item
    }
}

# 检查 MCP 配置
Write-Host "`n  --- MCP 连接器 ---" -ForegroundColor Cyan
$domains = @('commercial-legal','litigation-legal','employment-legal','privacy-legal','corporate-legal','ip-legal','product-legal','regulatory-legal','ai-governance-legal','law-student','legal-clinic','legal-builder-hub')
foreach ($d in $domains) {
    $upMcp = "$UpstreamDir/$d/.mcp.json"
    $patchMcp = "$PatchDir/connectors/$d.mcp.json"
    if (Test-Path $upMcp) {
        $upHash = (Get-FileHash $upMcp -Algorithm SHA256).Hash
        $paHash = (Get-FileHash $patchMcp -Algorithm SHA256).Hash
        if ($upHash -ne $paHash) {
            Write-Host "  [Δ] $d/.mcp.json 已变更" -ForegroundColor Yellow
            $changed += @{ Category='MCP'; Name="$d.mcp.json" }
        } else {
            Write-Host "  [✓] $d/.mcp.json 未变化" -ForegroundColor Green
        }
    }
}

# ---- [3] 汇总 ----
Write-Host "`n[3/4] 汇总" -ForegroundColor Yellow
Write-Host "  总检查项: $($checklist.Count + $domains.Count)"
Write-Host "  已变更: $($changed.Count)" -ForegroundColor Yellow
Write-Host "  未变化: $($unchanged.Count)" -ForegroundColor Green
Write-Host "  新增: $($new.Count)" -ForegroundColor Cyan

if ($changed.Count -gt 0 -or $new.Count -gt 0) {
    Write-Host "`n  ⚠ 上游有更新，建议审查后同步" -ForegroundColor Yellow
    Write-Host "  审查后运行: .\patches\zhou210712\diff-tool.ps1 -Update" -ForegroundColor DarkGray
}

# ---- [4] 可选：更新快照 ----
if ($Update -and ($changed.Count -gt 0 -or $new.Count -gt 0)) {
    Write-Host "`n[4/4] 更新快照..." -ForegroundColor Yellow
    foreach ($item in $changed + $new) {
        $upstreamFile = "$UpstreamDir/$($item.Upstream)"
        $patchFile = "$PatchDir/$($item.Patch)"
        if (Test-Path $upstreamFile) {
            $null = New-Item -ItemType Directory -Force (Split-Path $patchFile -Parent)
            Copy-Item $upstreamFile $patchFile -Force
            Write-Host "  已更新: $($item.Name)" -ForegroundColor Green
        }
    }
    Write-Host "  快照已同步。请在 CHANGELOG.md 中记录本次变更。" -ForegroundColor Green
}

# 清理临时目录
Write-Host "`n清理临时文件..."
Remove-Item -Recurse -Force $UpstreamDir -ErrorAction SilentlyContinue
Write-Host "完成。" -ForegroundColor Green

