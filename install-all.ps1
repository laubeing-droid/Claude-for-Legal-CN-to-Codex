<#
.SYNOPSIS
  统一安装入口 — 自动检测并部署到全部已安装平台
.DESCRIPTION
  加载 platforms.ps1，自动检测四平台，对已安装的平台调用对应安装脚本。
  供 laubeing-droid 旗下全部仓库的 install.ps1 调用。
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceSkillsDir,

    [string]$SkillNamespace = 'claude-for-legal-cn',

    [string]$McpConfigsDir,

    [switch]$SkipClaudeCode,
    [switch]$SkipWorkBuddy,
    [switch]$SkipTrae
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 加载平台适配框架
. "$ScriptDir\platforms.ps1"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  laubeing-droid 四平台统一安装" -ForegroundColor Cyan
Write-Host "  技能: $SkillNamespace" -ForegroundColor DarkGray
Write-Host "  来源: $SourceSkillsDir" -ForegroundColor DarkGray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检测平台
$platforms = Get-AllPlatforms
$active = $platforms | Where-Object { $_.Installed }

# 应用跳过参数
if ($SkipClaudeCode) { $active = $active | Where-Object { $_.Id -ne 'claude-code' } }
if ($SkipWorkBuddy) { $active = $active | Where-Object { $_.Id -ne 'workbuddy' } }
if ($SkipTrae)      { $active = $active | Where-Object { $_.Id -ne 'trae' } }

if ($active.Count -eq 0) {
    Write-Host "[!] 未检测到任何平台。将仅生成 Codex Desktop 配置。" -ForegroundColor Yellow
    $active = @($platforms | Where-Object { $_.Id -eq 'codex' })
}

# 确保 MCP 配置目录存在
if ($McpConfigsDir -and (-not (Test-Path $McpConfigsDir))) {
    New-Item -ItemType Directory -Force $McpConfigsDir | Out-Null
}

# 对每个平台执行安装
foreach ($p in $active) {
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host "  平台: $($p.Name) ($($p.Id))" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor DarkGray

    $installScript = Join-Path $ScriptDir $p.InstallScript
    if (Test-Path $installScript) {
        & $installScript -SourceSkillsDir $SourceSkillsDir -SkillNamespace $SkillNamespace
    } else {
        Write-Host "  [!] 安装脚本未找到: $installScript — 使用通用部署" -ForegroundColor DarkYellow
        Deploy-SkillsToPlatform -Platform $p -SourceSkillsDir $SourceSkillsDir -SkillNamespace $SkillNamespace
    }
}

# 完成报告
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  四平台安装完成" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Show-PlatformStatus
