<#
.SYNOPSIS
  Codex Desktop 平台安装器
.DESCRIPTION
  将技能/MCP配置部署到 ~/.codex/skills/ + ~/.codex/config.toml
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceSkillsDir,

    [string]$SkillNamespace = 'claude-for-legal-cn'
)

$ErrorActionPreference = 'Stop'
$SkillsTarget = "$env:USERPROFILE\.codex\skills\$SkillNamespace"
$ConfigPath  = "$env:USERPROFILE\.codex\config.toml"

Write-Host "=== Codex Desktop 安装 ===" -ForegroundColor Green

# 技能部署
Write-Host "[1/2] 部署技能文件..." -ForegroundColor Yellow
if (Test-Path $SkillsTarget) {
    Remove-Item $SkillsTarget -Recurse -Force
}
New-Item -ItemType Directory -Force (Split-Path $SkillsTarget -Parent) | Out-Null
Copy-Item -Path $SourceSkillsDir -Destination $SkillsTarget -Recurse -Force
Write-Host "  [OK] 技能已部署到 $SkillsTarget" -ForegroundColor Green

# MCP 配置（如果存在）
$mcpJson = Join-Path $SourceSkillsDir '..' 'mcp-configs' 'codex.toml'
if (Test-Path $mcpJson) {
    Write-Host "[2/2] 部署 MCP 配置..." -ForegroundColor Yellow
    $tomlBlock = Get-Content $mcpJson -Raw -Encoding UTF8
    Add-Content -Path $ConfigPath -Value "`n$tomlBlock" -Encoding UTF8
    Write-Host "  [OK] MCP 配置已添加到 $ConfigPath" -ForegroundColor Green
} else {
    Write-Host "[2/2] 无 MCP 配置" -ForegroundColor DarkGray
}

Write-Host "Codex Desktop 安装完成" -ForegroundColor Green
