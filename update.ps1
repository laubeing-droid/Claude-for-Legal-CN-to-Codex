<#
.SYNOPSIS
  手动更新 Codex 中国法律技能包
.DESCRIPTION
  从上游拉取最新内容，同步技能 + MCP 连接器配置到 ~/.codex/skills/。
#>

$ErrorActionPreference = 'Stop'
$SkillsDir = "$env:USERPROFILE\.codex\skills"
$UpstreamDir = "$env:USERPROFILE\.codex\vendor\claude-for-legal-CN"

$domains = @(
    'commercial-legal','privacy-legal','product-legal','corporate-legal',
    'employment-legal','regulatory-legal','ai-governance-legal','litigation-legal',
    'law-student','legal-clinic','legal-builder-hub','ip-legal'
)

Write-Host '=== 更新 Codex 中国法律技能 ===' -ForegroundColor Green

if (-not (Test-Path "$UpstreamDir\.git")) {
    Write-Host '[错误] 上游内容不存在。请先运行 install.ps1。' -ForegroundColor Red
    exit 1
}

Push-Location $UpstreamDir
$result = git pull 2>&1
Pop-Location
Write-Host "  [上游] $($result -join '')"

function Add-LegalMcpServers {
    param($McpPath)
    $mcp = Get-Content $McpPath -Encoding UTF8 | ConvertFrom-Json
    if (-not $mcp.mcpServers.PSObject.Properties.Name -contains 'chineselaw') {
        $mcp.mcpServers | Add-Member -NotePropertyName 'chineselaw' -NotePropertyValue @{
            type = "stdio"
            command = "npx"
            args = @("-y", "chineselaw-mcp")
            env = @{ CHINESELAW_API_KEY = "你的_API_KEY" }
            title = "chineselaw（元典智库）"
            description = "中国法律检索 — 33 个工具：法规检索、法条查询、案例检索、企业信息查询。需在 https://open.chineselaw.com 注册获取 API Key。"
        }
    }
    if (-not $mcp.mcpServers.PSObject.Properties.Name -contains '北大法宝') {
        $mcp.mcpServers | Add-Member -NotePropertyName '北大法宝' -NotePropertyValue @{
            type = "http"
            url = "https://apim-gateway.pkulaw.com/{{YOUR_SERVICE_ID}}"
            headers = @{ Authorization = "Bearer {{YOUR_ACCESS_TOKEN}}" }
            title = "北大法宝"
            description = "中国法律法规与裁判文书检索 — 需在 https://mcp.pkulaw.com 注册获取 Service ID 和 Token。"
        }
    }
    $mcp | ConvertTo-Json -Depth 10 | Out-File $McpPath -Encoding UTF8 -Force
}

$count = 0
foreach ($name in $domains) {
    $src = "$UpstreamDir\$name"
    $tgt = "$SkillsDir\$name"
    if (-not (Test-Path $src)) { continue }
    if (-not (Test-Path $tgt)) { $null = New-Item -ItemType Directory -Force $tgt }

    Copy-Item "$src\CLAUDE.md" "$tgt\CLAUDE.md" -Force -ErrorAction SilentlyContinue
    Copy-Item "$src\README.md" "$tgt\README.md" -Force -ErrorAction SilentlyContinue
    if (Test-Path "$src\.mcp.json") {
        Copy-Item "$src\.mcp.json" "$tgt\.mcp.json" -Force
        try { Add-LegalMcpServers -McpPath "$tgt\.mcp.json" } catch {
            Write-Host "  [警告] MCP 注入失败 ($name): $_" -ForegroundColor Yellow
        }
    }
    if (Test-Path "$src\references") {
        $null = New-Item -ItemType Directory -Force "$tgt\references"
        Get-ChildItem "$src\references\*" -File -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item $_.FullName "$tgt\references\" -Force
        }
    }
    if (Test-Path "$src\skills") {
        Get-ChildItem "$src\skills" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $subTgt = "$tgt\skills\$($_.Name)"
            $null = New-Item -ItemType Directory -Force $subTgt
            if (Test-Path "$($_.FullName)\SKILL.md") { Copy-Item "$($_.FullName)\SKILL.md" "$subTgt\SKILL.md" -Force }
        }
    }
    if (Test-Path "$src\agents") {
        $null = New-Item -ItemType Directory -Force "$tgt\agents"
        Get-ChildItem "$src\agents\*" -File -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item $_.FullName "$tgt\agents\" -Force
        }
    }
    $count++
}

# 根技能
$rootTgt = "$SkillsDir\codex-for-legal-cn"
if (Test-Path "$rootTgt\.mcp.json") {
    try { Add-LegalMcpServers -McpPath "$rootTgt\.mcp.json" } catch {}
}

Write-Host "  已更新 $count 个技能领域（含 MCP 连接器）"
Write-Host ''
Write-Host '更新完成。重启 Codex Desktop 使新内容生效。' -ForegroundColor Green
