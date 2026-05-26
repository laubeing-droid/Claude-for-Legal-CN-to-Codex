<#
.SYNOPSIS
  WorkBuddy 平台安装器
.DESCRIPTION
  将技能部署到 ~/.workbuddy/skills/，同时生成 ZIP 包
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceSkillsDir,

    [string]$SkillNamespace = 'claude-for-legal-cn'
)

$ErrorActionPreference = 'Stop'
$SkillsTarget = "$env:USERPROFILE\.workbuddy\skills\$SkillNamespace"
$ZipTarget    = "$env:USERPROFILE\.workbuddy\skills\zip-packages"
$ConfigPath   = "$env:USERPROFILE\.workbuddy\config.json"

Write-Host "=== WorkBuddy 安装 ===" -ForegroundColor Green

# 技能部署（解压版）
Write-Host "[1/3] 部署技能文件（解压版）..." -ForegroundColor Yellow
if (Test-Path $SkillsTarget) {
    Remove-Item $SkillsTarget -Recurse -Force
}
New-Item -ItemType Directory -Force (Split-Path $SkillsTarget -Parent) | Out-Null
Copy-Item -Path $SourceSkillsDir -Destination $SkillsTarget -Recurse -Force
Write-Host "  [OK] 技能已部署到 $SkillsTarget" -ForegroundColor Green

# ZIP 包生成
Write-Host "[2/3] 生成 ZIP 包..." -ForegroundColor Yellow
if (-not (Test-Path $ZipTarget)) { New-Item -ItemType Directory -Force $ZipTarget | Out-Null }
Get-ChildItem $SourceSkillsDir -Directory | ForEach-Object {
    $skillName = $_.Name
    $zipPath = Join-Path $ZipTarget "$SkillNamespace-$skillName.zip"
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Compress-Archive -Path "$($_.FullName)\*" -DestinationPath $zipPath -Force
    Write-Host "  [ZIP] $SkillNamespace-$skillName.zip" -ForegroundColor DarkGray
}
Write-Host "  [OK] ZIP 包已生成到 $ZipTarget" -ForegroundColor Green

# MCP 配置
$mcpJson = Join-Path $SourceSkillsDir '..' 'mcp-configs' 'workbuddy.json'
if (Test-Path $mcpJson) {
    Write-Host "[3/3] 部署 MCP 配置..." -ForegroundColor Yellow
    $newConfig = Get-Content $mcpJson -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    $existing = @{}
    if (Test-Path $ConfigPath) {
        $existing = Get-Content $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    }
    if (-not $existing.ContainsKey('mcpServers')) { $existing['mcpServers'] = @{} }
    foreach ($key in $newConfig.Keys) {
        $existing['mcpServers'][$key] = $newConfig[$key]
    }
    $existing | ConvertTo-Json -Depth 4 | Set-Content -Path $ConfigPath -Encoding UTF8
    Write-Host "  [OK] MCP 配置已合并到 $ConfigPath" -ForegroundColor Green
} else {
    Write-Host "[3/3] 无 MCP 配置" -ForegroundColor DarkGray
}

Write-Host "WorkBuddy 安装完成" -ForegroundColor Green
