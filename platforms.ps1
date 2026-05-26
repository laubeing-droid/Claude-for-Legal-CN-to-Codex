<#
.SYNOPSIS
  四平台统一检测与适配器框架
.DESCRIPTION
  检测 Codex Desktop / Claude Code / WorkBuddy / Trae 四种 AI 编程平台，
  为每个平台提供：MCP 配置生成、技能部署、环境检测。
  供 laubeing-droid 旗下全部仓库统一调用。
#>

# ============================================================
# 1. 平台检测
# ============================================================

function Get-AllPlatforms {
    <#
    .SYNOPSIS
      检测所有平台的安装状态和配置信息
    .OUTPUTS
      平台信息对象数组
    #>
    $platforms = @()

    # ── Codex Desktop ──
    $codexSkillsDir  = "$env:USERPROFILE\.codex\skills"
    $codexConfigPath = "$env:USERPROFILE\.codex\config.toml"
    $codexInstalled  = Test-Path "$env:USERPROFILE\.codex"
    $platforms += [PSCustomObject]@{
        Id            = 'codex'
        Name          = 'Codex Desktop'
        Vendor        = 'OpenAI'
        Installed     = $codexInstalled
        SkillsDir     = $codexSkillsDir
        ConfigPath    = $codexConfigPath
        ConfigFormat  = 'toml'
        McpSection    = 'mcp_servers'
        PluginFormat  = 'SKILL.md (YAML frontmatter)'
        PluginExt     = '.md'
        MarketFormat  = 'Codex Marketplace'
        InstallScript = 'install-codex.ps1'
    }

    # ── Claude Code (CLI) ──
    $ccConfigPath = "$env:USERPROFILE\.claude\settings.json"
    $ccInstalled  = Test-Path $ccConfigPath
    $platforms += [PSCustomObject]@{
        Id            = 'claude-code'
        Name          = 'Claude Code'
        Vendor        = 'Anthropic'
        Installed     = $ccInstalled
        SkillsDir     = "$env:USERPROFILE\.claude\plugins"
        ConfigPath    = $ccConfigPath
        ConfigFormat  = 'json'
        McpSection    = 'mcpServers'
        PluginFormat  = 'SKILL.md + /plugin 命令'
        PluginExt     = '.md'
        MarketFormat  = '/plugin marketplace add'
        InstallScript = 'install-claude-code.ps1'
    }

    # ── Claude Desktop ──
    $cdConfigPath = "$env:APPDATA\Claude\claude_desktop_config.json"
    if (-not (Test-Path $cdConfigPath)) {
        $cdConfigPath = "$env:LOCALAPPDATA\Claude\claude_desktop_config.json"
    }
    $cdInstalled = Test-Path $cdConfigPath
    $platforms += [PSCustomObject]@{
        Id            = 'claude-desktop'
        Name          = 'Claude Desktop'
        Vendor        = 'Anthropic'
        Installed     = $cdInstalled
        SkillsDir     = "$env:APPDATA\Claude\plugins"
        ConfigPath    = $cdConfigPath
        ConfigFormat  = 'json'
        McpSection    = 'mcpServers'
        PluginFormat  = 'SKILL.md + Claude Desktop Plugin'
        PluginExt     = '.md'
        MarketFormat  = 'Claude Desktop 配置'
        InstallScript = 'install-claude-desktop.ps1'
    }

    # ── WorkBuddy (豆包/CodeBuddy 小程序) ──
    $wbSkillsDir  = "$env:USERPROFILE\.workbuddy\skills"
    $wbConfigPath = "$env:USERPROFILE\.workbuddy\config.json"
    $wbInstalled  = Test-Path "$env:USERPROFILE\.workbuddy"
    $platforms += [PSCustomObject]@{
        Id            = 'workbuddy'
        Name          = 'WorkBuddy'
        Vendor        = 'Tencent/ByteDance'
        Installed     = $wbInstalled
        SkillsDir     = $wbSkillsDir
        ConfigPath    = $wbConfigPath
        ConfigFormat  = 'json'
        McpSection    = 'mcpServers'
        PluginFormat  = 'ZIP 包（每技能独立）'
        PluginExt     = '.zip'
        MarketFormat  = 'ZIP 导入'
        InstallScript = 'install-workbuddy.ps1'
    }

    # ── Trae (字节跳动 AI IDE) ──
    # Trae 基于 VS Code，配置文件路径类似
    $traeConfigDir = "$env:USERPROFILE\.trae"
    $traeExtDir    = "$env:USERPROFILE\.trae\extensions"
    # macOS: ~/Library/Application Support/Trae/
    # Windows 备用路径
    if (-not (Test-Path $traeConfigDir)) {
        $traeConfigDir = "$env:APPDATA\Trae"
    }
    $traeInstalled = Test-Path $traeConfigDir
    $platforms += [PSCustomObject]@{
        Id            = 'trae'
        Name          = 'Trae'
        Vendor        = 'ByteDance'
        Installed     = $traeInstalled
        SkillsDir     = "$traeConfigDir\skills"
        ConfigPath    = "$traeConfigDir\mcp.json"
        ConfigFormat  = 'json'
        McpSection    = 'mcpServers'
        PluginFormat  = 'SKILL.md + Trae 插件'
        PluginExt     = '.md'
        MarketFormat  = 'Trae 插件市场'
        InstallScript = 'install-trae.ps1'
    }

    return $platforms
}

# ============================================================
# 2. MCP 配置生成器（多格式）
# ============================================================

function New-CodexMcpConfig {
    param([string]$ServerName, [string]$Command, [string[]]$Args, [hashtable]$Env = @{})
    <#
    .SYNOPSIS
      生成 Codex Desktop TOML 格式 MCP 配置
    #>
    $lines = @()
    $lines += "[mcp_servers.$ServerName]"
    $lines += "command = `"$Command`""
    if ($Args.Count -gt 0) {
        $argsStr = ($Args | ForEach-Object { "`"$_`"" }) -join ', '
        $lines += "args = [$argsStr]"
    }
    if ($Env.Count -gt 0) {
        $envLines = $Env.GetEnumerator() | ForEach-Object { "  $($_.Key) = `"$($_.Value)`"" }
        $lines += "[mcp_servers.${ServerName}.env]"
        $lines += $envLines
    }
    return $lines -join "`n"
}

function New-ClaudeMcpConfig {
    param([string]$ServerName, [string]$Command, [string[]]$Args, [hashtable]$Env = @{})
    <#
    .SYNOPSIS
      生成 Claude Code / Claude Desktop JSON 格式 MCP 配置
    #>
    $config = @{
        command = $Command
    }
    if ($Args.Count -gt 0) {
        $config['args'] = $Args
    }
    if ($Env.Count -gt 0) {
        $config['env'] = $Env
    }
    return @{ $ServerName = $config }
}

function New-TraeMcpConfig {
    param([string]$ServerName, [string]$Command, [string[]]$Args, [hashtable]$Env = @{})
    <#
    .SYNOPSIS
      生成 Trae JSON 格式 MCP 配置
      格式与 Claude Code 相同（均基于 JSON）
    #>
    return New-ClaudeMcpConfig -ServerName $ServerName -Command $Command -Args $Args -Env $Env
}

function New-WorkBuddyMcpConfig {
    param([string]$ServerName, [string]$Command, [string[]]$Args, [hashtable]$Env = @{})
    <#
    .SYNOPSIS
      生成 WorkBuddy JSON 格式 MCP 配置
    #>
    $config = @{
        command = $Command
        type    = 'stdio'
    }
    if ($Args.Count -gt 0) {
        $config['args'] = $Args
    }
    if ($Env.Count -gt 0) {
        $config['env'] = $Env
    }
    return @{ $ServerName = $config }
}

# ============================================================
# 3. MCP 配置写入（多平台）
# ============================================================

function Write-McpToCodex {
    param([string]$ConfigPath, [string]$ServerName, [string]$TomlBlock)
    $dir = Split-Path -Parent $ConfigPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    if (-not (Test-Path $ConfigPath)) { New-Item -ItemType File -Force $ConfigPath | Out-Null }
    $content = Get-Content $ConfigPath -Encoding UTF8 -Raw -ErrorAction SilentlyContinue
    if ($content -match "(?ms)^\[mcp_servers\.$([regex]::Escape($ServerName))\]") {
        Write-Host "    [=] Codex Desktop: $ServerName 已存在" -ForegroundColor DarkGray
        return $false
    }
    Add-Content -Path $ConfigPath -Value "`n$TomlBlock" -Encoding UTF8
    Write-Host "    [+] Codex Desktop: $ServerName 已添加" -ForegroundColor Green
    return $true
}

function Write-McpToJson {
    param([string]$ConfigPath, [string]$ServerName, [hashtable]$ServerConfig, [string]$PlatformName)
    $dir = Split-Path -Parent $ConfigPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }

    $json = @{}
    if (Test-Path $ConfigPath) {
        try {
            $json = Get-Content $ConfigPath -Encoding UTF8 -Raw | ConvertFrom-Json -AsHashtable
        }
        catch { $json = @{} }
    }

    if (-not $json.ContainsKey('mcpServers')) { $json['mcpServers'] = @{} }
    if ($json['mcpServers'].ContainsKey($ServerName)) {
        Write-Host "    [=] $($PlatformName): $ServerName 已存在" -ForegroundColor DarkGray
        return $false
    }

    $json['mcpServers'][$ServerName] = $ServerConfig
    $json | ConvertTo-Json -Depth 4 | Set-Content -Path $ConfigPath -Encoding UTF8
    Write-Host "    [+] $($PlatformName): $ServerName 已添加" -ForegroundColor Green
    return $true
}

function Write-McpToPlatform {
    param(
        [PSCustomObject]$Platform,
        [string]$ServerName,
        [string]$Command,
        [string[]]$Args,
        [hashtable]$Env = @{}
    )
    switch ($Platform.Id) {
        'codex' {
            $toml = New-CodexMcpConfig -ServerName $ServerName -Command $Command -Args $Args -Env $Env
            return Write-McpToCodex -ConfigPath $Platform.ConfigPath -ServerName $ServerName -TomlBlock $toml
        }
        'claude-code' {
            $cfg = New-ClaudeMcpConfig -ServerName $ServerName -Command $Command -Args $Args -Env $Env
            return Write-McpToJson -ConfigPath $Platform.ConfigPath -ServerName $ServerName -ServerConfig $cfg[$ServerName] -PlatformName $Platform.Name
        }
        'claude-desktop' {
            $cfg = New-ClaudeMcpConfig -ServerName $ServerName -Command $Command -Args $Args -Env $Env
            return Write-McpToJson -ConfigPath $Platform.ConfigPath -ServerName $ServerName -ServerConfig $cfg[$ServerName] -PlatformName $Platform.Name
        }
        'trae' {
            $cfg = New-TraeMcpConfig -ServerName $ServerName -Command $Command -Args $Args -Env $Env
            return Write-McpToJson -ConfigPath $Platform.ConfigPath -ServerName $ServerName -ServerConfig $cfg[$ServerName] -PlatformName $Platform.Name
        }
        'workbuddy' {
            $cfg = New-WorkBuddyMcpConfig -ServerName $ServerName -Command $Command -Args $Args -Env $Env
            return Write-McpToJson -ConfigPath $Platform.ConfigPath -ServerName $ServerName -ServerConfig $cfg[$ServerName] -PlatformName $Platform.Name
        }
    }
}

# ============================================================
# 4. 技能部署（多平台）
# ============================================================

function Deploy-SkillsToPlatform {
    param(
        [PSCustomObject]$Platform,
        [string]$SourceSkillsDir,
        [string]$SkillNamespace
    )
    <#
    .SYNOPSIS
      将技能目录部署到指定平台
    #>
    $targetDir = Join-Path $Platform.SkillsDir $SkillNamespace
    if (-not (Test-Path $Platform.SkillsDir)) {
        New-Item -ItemType Directory -Force $Platform.SkillsDir | Out-Null
    }

    # 复制技能文件
    if (Test-Path $targetDir) {
        Remove-Item $targetDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    Copy-Item -Path $SourceSkillsDir -Destination $targetDir -Recurse -Force

    Write-Host "    [+] $($Platform.Name): 技能已部署到 $targetDir" -ForegroundColor Green

    # WorkBuddy 额外：生成 ZIP 包
    if ($Platform.Id -eq 'workbuddy') {
        $zipDir = Join-Path $Platform.SkillsDir 'zip-packages'
        if (-not (Test-Path $zipDir)) { New-Item -ItemType Directory -Force $zipDir | Out-Null }
        Get-ChildItem $targetDir -Directory | ForEach-Object {
            $skillName = $_.Name
            $zipPath = Join-Path $zipDir "$skillName.zip"
            if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
            Compress-Archive -Path "$($_.FullName)\*" -DestinationPath $zipPath -Force
            Write-Host "      [ZIP] $skillName.zip" -ForegroundColor DarkGray
        }
    }
}

# ============================================================
# 5. 平台状态报告
# ============================================================

function Show-PlatformStatus {
    <#
    .SYNOPSIS
      输出所有平台的检测状态
    #>
    $platforms = Get-AllPlatforms
    Write-Host ""
    Write-Host "=== 四平台检测状态 ===" -ForegroundColor Cyan
    Write-Host ""
    foreach ($p in $platforms) {
        $icon = if ($p.Installed) { '[✓]' } else { '[ ]' }
        $color = if ($p.Installed) { 'Green' } else { 'DarkGray' }
        Write-Host "  $icon $($p.Name) ($($p.Vendor))" -ForegroundColor $color
        if ($p.Installed) {
            Write-Host "      配置: $($p.ConfigPath)" -ForegroundColor DarkGray
            Write-Host "      技能: $($p.SkillsDir)" -ForegroundColor DarkGray
            Write-Host "      格式: $($p.ConfigFormat) | $($p.PluginFormat)" -ForegroundColor DarkGray
        }
    }
    $active = ($platforms | Where-Object { $_.Installed }).Count
    Write-Host ""
    Write-Host "  已安装: $active / $($platforms.Count)" -ForegroundColor $(if ($active -gt 0) { 'Green' } else { 'Yellow' })
    Write-Host ""
}

# ============================================================
# 6. 统一安装入口
# ============================================================

function Install-ToAllPlatforms {
    param(
        [string]$MCPHubPath,
        [string]$SkillsSourceDir,
        [string]$SkillNamespace = 'claude-for-legal-cn'
    )
    <#
    .SYNOPSIS
      一键安装到所有已检测到的平台
    #>
    $platforms = Get-AllPlatforms
    $active = $platforms | Where-Object { $_.Installed }

    if ($active.Count -eq 0) {
        Write-Host "[!] 未检测到任何已安装平台。将至少为 Codex Desktop 创建配置。" -ForegroundColor Yellow
        $active = @($platforms | Where-Object { $_.Id -eq 'codex' })
    }

    Write-Host "=== 多平台部署 ===" -ForegroundColor Green
    Write-Host "  目标平台: $(($active | ForEach-Object { $_.Name }) -join ', ')" -ForegroundColor Cyan
    Write-Host ""

    foreach ($p in $active) {
        Write-Host "[$($p.Name)]" -ForegroundColor Yellow
        # MCP 配置（如果有 MCP Hub）
        if ($MCPHubPath -and (Test-Path $MCPHubPath)) {
            Write-Host "  部署 MCP 配置..." -ForegroundColor DarkGray
            & "$MCPHubPath\install.ps1" -TargetPlatform $p.Id
        }
        # 技能部署
        if ($SkillsSourceDir -and (Test-Path $SkillsSourceDir)) {
            Write-Host "  部署技能..." -ForegroundColor DarkGray
            Deploy-SkillsToPlatform -Platform $p -SourceSkillsDir $SkillsSourceDir -SkillNamespace $SkillNamespace
        }
        Write-Host ""
    }

    Write-Host "=== 部署完成 ===" -ForegroundColor Green
    Show-PlatformStatus
}

# ============================================================
# 导出
# ============================================================
Write-Host "platforms.ps1 已加载 — 四平台适配框架就绪" -ForegroundColor Green
Write-Host "  可用函数: Get-AllPlatforms, Show-PlatformStatus, Install-ToAllPlatforms" -ForegroundColor DarkGray
Write-Host "  配置函数: New-CodexMcpConfig, New-ClaudeMcpConfig, New-TraeMcpConfig, New-WorkBuddyMcpConfig" -ForegroundColor DarkGray
Write-Host "  部署函数: Write-McpToPlatform, Deploy-SkillsToPlatform" -ForegroundColor DarkGray
