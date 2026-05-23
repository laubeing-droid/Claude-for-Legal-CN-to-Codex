<#
.SYNOPSIS
  一键安装 Codex 中国法律技能包
.DESCRIPTION
  1. 克隆上游法律内容 (SH88-source/claude-for-legal-CN)
  2. 安装 SKILL.md 包装层到 ~/.codex/skills/
  3. 注入 MCP 连接器配置（chineselaw-mcp + 北大法宝）
  4. 设置内容链接便于自动更新
#>

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsDir = "$env:USERPROFILE\.codex\skills"
$VendorDir = "$env:USERPROFILE\.codex\vendor"
$UpstreamDir = "$VendorDir\claude-for-legal-CN"
$GitUrl = 'https://github.com/SH88-source/claude-for-legal-CN.git'

Write-Host '=== Codex 中国法律技能包 安装 ===' -ForegroundColor Green
Write-Host ''

Write-Host '[1/4] 克隆上游法律内容...' -ForegroundColor Yellow
$null = New-Item -ItemType Directory -Force $VendorDir
if (Test-Path "$UpstreamDir\README.md") {
    Push-Location $UpstreamDir
    git pull 2>&1 | Out-Null
    Pop-Location
    Write-Host "  上游内容已存在，已拉取最新: $UpstreamDir"
} else {
    Write-Host "  正在克隆: $GitUrl"
    Push-Location $VendorDir
    git clone $GitUrl claude-for-legal-CN 2>&1 | Out-Null
    Pop-Location
    if (-not (Test-Path "$UpstreamDir\README.md")) {
        Write-Host '  [错误] 克隆失败，请检查网络连接' -ForegroundColor Red
        exit 1
    }
    Write-Host '  上游内容已克隆'
}

Write-Host '[2/4] 安装技能包装层...' -ForegroundColor Yellow
$domains = @(
    'commercial-legal','privacy-legal','product-legal','corporate-legal',
    'employment-legal','regulatory-legal','ai-governance-legal','litigation-legal',
    'law-student','legal-clinic','legal-builder-hub','ip-legal'
)

function Add-LegalMcpServers {
    param($McpPath)
    $mcp = Get-Content $McpPath -Encoding UTF8 | ConvertFrom-Json

    # chineselaw-mcp — 元典智库 API 封装，33 个工具
    if (-not $mcp.mcpServers.PSObject.Properties.Name -contains 'chineselaw') {
        $mcp.mcpServers | Add-Member -NotePropertyName 'chineselaw' -NotePropertyValue @{
            type = "stdio"
            command = "npx"
            args = @("-y", "chineselaw-mcp")
            env = @{
                CHINESELAW_API_KEY = "你的_API_KEY"
            }
            title = "chineselaw（元典智库）"
            description = "中国法律检索 — 33 个工具：法规检索、法条查询、案例检索、企业信息查询。需在 https://open.chineselaw.com 注册获取 API Key。"
        }
    }

    # 北大法宝 MCP
    if (-not $mcp.mcpServers.PSObject.Properties.Name -contains '北大法宝') {
        $mcp.mcpServers | Add-Member -NotePropertyName '北大法宝' -NotePropertyValue @{
            type = "http"
            url = "https://apim-gateway.pkulaw.com/{{YOUR_SERVICE_ID}}"
            headers = @{
                Authorization = "Bearer {{YOUR_ACCESS_TOKEN}}"
            }
            title = "北大法宝"
            description = "中国法律法规与裁判文书检索 — 需在 https://mcp.pkulaw.com 注册获取 Service ID 和 Token。"
        }
    }

    $mcp | ConvertTo-Json -Depth 10 | Out-File $McpPath -Encoding UTF8 -Force
}

foreach ($name in $domains) {
    $srcSkill = "$RepoRoot\skills\$name\SKILL.md"
    $tgtDir = "$SkillsDir\$name"
    $null = New-Item -ItemType Directory -Force $tgtDir
    if (Test-Path $srcSkill) { Copy-Item $srcSkill "$tgtDir\SKILL.md" -Force }

    $upstreamModule = "$UpstreamDir\$name"
    if (Test-Path "$upstreamModule\CLAUDE.md") { Copy-Item "$upstreamModule\CLAUDE.md" "$tgtDir\CLAUDE.md" -Force }
    if (Test-Path "$upstreamModule\README.md") { Copy-Item "$upstreamModule\README.md" "$tgtDir\README.md" -Force }

    # .mcp.json：复制上游并注入中国法律 MCP 连接器
    if (Test-Path "$upstreamModule\.mcp.json") {
        Copy-Item "$upstreamModule\.mcp.json" "$tgtDir\.mcp.json" -Force
        try { Add-LegalMcpServers -McpPath "$tgtDir\.mcp.json" } catch {
            Write-Host "  [警告] MCP 注入失败 ($name): $_" -ForegroundColor Yellow
        }
    }

    if (Test-Path "$upstreamModule\references") {
        $null = New-Item -ItemType Directory -Force "$tgtDir\references"
        Get-ChildItem "$upstreamModule\references\*" -File -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item $_.FullName "$tgtDir\references\" -Force
        }
    }
    if (Test-Path "$upstreamModule\skills") {
        Get-ChildItem "$upstreamModule\skills" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $subTgt = "$tgtDir\skills\$($_.Name)"
            $null = New-Item -ItemType Directory -Force $subTgt
            if (Test-Path "$($_.FullName)\SKILL.md") { Copy-Item "$($_.FullName)\SKILL.md" "$subTgt\SKILL.md" -Force }
        }
    }
    if (Test-Path "$upstreamModule\agents") {
        $null = New-Item -ItemType Directory -Force "$tgtDir\agents"
        Get-ChildItem "$upstreamModule\agents\*" -File -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item $_.FullName "$tgtDir\agents\" -Force
        }
    }
}

# 根技能
$rootTgt = "$SkillsDir\codex-for-legal-cn"
$null = New-Item -ItemType Directory -Force $rootTgt
Copy-Item "$RepoRoot\skills\codex-for-legal-cn\SKILL.md" "$rootTgt\SKILL.md" -Force
if (Test-Path "$rootTgt\.mcp.json") {
    try { Add-LegalMcpServers -McpPath "$rootTgt\.mcp.json" } catch {}
} else {
    @{ mcpServers = @{} } | ConvertTo-Json | Out-File "$rootTgt\.mcp.json" -Encoding UTF8 -Force
    try { Add-LegalMcpServers -McpPath "$rootTgt\.mcp.json" } catch {}
}

Write-Host '  技能安装完成（含 MCP 连接器配置）'

Write-Host '[3/4] 配置 PowerShell 执行策略...' -ForegroundColor Yellow
$policy = Get-ExecutionPolicy -Scope CurrentUser 2>$null
if ($policy -eq 'Restricted') {
    Set-ExecutionPolicy -Scope CurrentUser -RemoteSigned -Force
    Write-Host '  执行策略已设为 RemoteSigned'
} else {
    Write-Host '  执行策略正常'
}

Write-Host '[4/4] 验证安装...' -ForegroundColor Yellow
$missing = @()
$all = $domains + @('codex-for-legal-cn')
foreach ($name in $all) {
    if (-not (Test-Path "$SkillsDir\$name\SKILL.md")) { $missing += $name }
}
if ($missing.Count -eq 0) {
    Write-Host "  全部 $($all.Count) 个技能安装成功" -ForegroundColor Green
} else {
    Write-Host "  以下技能缺失: $($missing -join ', ')" -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host '安装完成！请重启 Codex Desktop 使技能生效。' -ForegroundColor Green
Write-Host ''
Write-Host 'MCP 法律检索连接器已预配置：' -ForegroundColor Cyan
Write-Host '  1. chineselaw（元典智库）— 33 个工具，推荐首选' -ForegroundColor Cyan
Write-Host '     注册: https://open.chineselaw.com → 获取 API Key' -ForegroundColor Cyan
Write-Host '  2. 北大法宝 — 备选 HTTP 方案' -ForegroundColor Cyan
Write-Host '     注册: https://mcp.pkulaw.com → 获取 Service ID + Token' -ForegroundColor Cyan
Write-Host '  配置指南见 docs/connectors.md' -ForegroundColor Cyan
