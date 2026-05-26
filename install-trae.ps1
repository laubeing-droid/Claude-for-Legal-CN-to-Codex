<#
.SYNOPSIS
  Trae 平台安装器
.DESCRIPTION
  将技能/MCP配置部署到 ~/.trae/skills/ + ~/.trae/mcp.json
  (Windows: %USERPROFILE%\.trae\, macOS: ~/Library/Application Support/Trae/)
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceSkillsDir,

    [string]$SkillNamespace = 'claude-for-legal-cn'
)

$ErrorActionPreference = 'Stop'

# Trae 路径检测
$traeHome = "$env:USERPROFILE\.trae"
if (-not (Test-Path $traeHome)) {
    $traeHome = "$env:APPDATA\Trae"
}
if (-not (Test-Path $traeHome)) {
    $traeHome = "$env:LOCALAPPDATA\Trae"
}
# macOS fallback (PowerShell Core)
if ($IsMacOS -and -not (Test-Path $traeHome)) {
    $traeHome = "$HOME/Library/Application Support/Trae"
}

$SkillsTarget = Join-Path $traeHome 'skills' $SkillNamespace
$ConfigPath   = Join-Path $traeHome 'mcp.json'

Write-Host "=== Trae 安装 ===" -ForegroundColor Green
Write-Host "  Trae 路径: $traeHome" -ForegroundColor DarkGray

# 技能部署
Write-Host "[1/2] 部署技能文件..." -ForegroundColor Yellow
if (Test-Path $SkillsTarget) {
    Remove-Item $SkillsTarget -Recurse -Force
}
New-Item -ItemType Directory -Force (Split-Path $SkillsTarget -Parent) | Out-Null
Copy-Item -Path $SourceSkillsDir -Destination $SkillsTarget -Recurse -Force
Write-Host "  [OK] 技能已部署到 $SkillsTarget" -ForegroundColor Green

# MCP 配置
$mcpJson = Join-Path $SourceSkillsDir '..' 'mcp-configs' 'trae.json'
if (Test-Path $mcpJson) {
    Write-Host "[2/2] 部署 MCP 配置..." -ForegroundColor Yellow
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
    Write-Host "[2/2] 无 MCP 配置" -ForegroundColor DarkGray
}

Write-Host "Trae 安装完成" -ForegroundColor Green
