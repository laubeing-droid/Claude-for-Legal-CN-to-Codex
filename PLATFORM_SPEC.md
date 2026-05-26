# 四平台兼容接口规范 (Platform Interface Specification)

> **版本**: 1.0.0
> **适用范围**: laubeing-droid 全部仓库
> **强制执行**: 是

---

## 目录

1. [平台概述](#1-平台概述)
2. [技能文件规范](#2-技能文件规范)
3. [MCP 配置规范](#3-mcp-配置规范)
4. [安装脚本规范](#4-安装脚本规范)
5. [目录结构规范](#5-目录结构规范)
6. [平台接口对照表](#6-平台接口对照表)

---

## 1. 平台概述

### 1.1 Codex Desktop

| 属性 | 值 |
|:-----|:---|
| 厂商 | OpenAI |
| 配置目录 | `~/.codex/` |
| 配置文件 | `~/.codex/config.toml` |
| 技能目录 | `~/.codex/skills/` |
| MCP 配置格式 | TOML |
| MCP section | `[mcp_servers.SERVER_NAME]` |
| 技能文件格式 | SKILL.md (YAML frontmatter) |
| 平台标识 | `codex` |

**TOML MCP 配置模板**:
```toml
[mcp_servers.my-server]
command = "python"
args = ["server.py"]

[mcp_servers.my-server.env]
API_KEY = "xxx"
```

### 1.2 Claude Code

| 属性 | 值 |
|:-----|:---|
| 厂商 | Anthropic |
| 配置目录 | `~/.claude/` |
| 配置文件 | `~/.claude/settings.json` |
| 技能目录 | `~/.claude/plugins/` |
| MCP 配置格式 | JSON |
| MCP section | `mcpServers` |
| 技能文件格式 | SKILL.md + `/plugin` 命令 |
| 平台标识 | `claude-code` |

**JSON MCP 配置模板**:
```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["server.py"],
      "env": { "API_KEY": "xxx" }
    }
  }
}
```

### 1.3 WorkBuddy

| 属性 | 值 |
|:-----|:---|
| 厂商 | Tencent |
| 配置目录 | `~/.workbuddy/` |
| 配置文件 | `~/.workbuddy/config.json` |
| 技能目录 | `~/.workbuddy/skills/` |
| MCP 配置格式 | JSON |
| MCP section | `mcpServers` |
| 技能文件格式 | ZIP 包（每技能独立） |
| 平台标识 | `workbuddy` |

**WorkBuddy 特殊要求**:
- 每技能打包为独立 ZIP：`{命名空间}-{技能名}.zip`
- ZIP 内必须包含：`SKILL.md` + `references/` + `CLAUDE.md`（可选）
- ZIP 存放在：`~/.workbuddy/skills/zip-packages/`
- 同时部署解压版到：`~/.workbuddy/skills/{命名空间}/`

**WorkBuddy MCP 配置（含 type 字段）**:
```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["server.py"],
      "type": "stdio"
    }
  }
}
```

### 1.4 Trae

| 属性 | 值 |
|:-----|:---|
| 厂商 | ByteDance |
| 配置目录 (Win) | `~/.trae/` 或 `%APPDATA%/Trae/` |
| 配置目录 (Mac) | `~/Library/Application Support/Trae/` |
| 配置文件 | `{trae_home}/mcp.json` |
| 技能目录 | `{trae_home}/skills/` |
| MCP 配置格式 | JSON |
| MCP section | `mcpServers` |
| 技能文件格式 | SKILL.md |
| 平台标识 | `trae` |

**Trae MCP 配置（与 Claude Code 相同）**:
```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["server.py"]
    }
  }
}
```

---

## 2. 技能文件规范

### 2.1 SKILL.md 必填 frontmatter

```yaml
---
name: skill-name              # 英文标识，跨平台统一
description: >
  中文技能描述。控制在 160 字以内。
platforms: [codex, claude-code, workbuddy, trae]  # 必填
version: x.y.z
---
```

### 2.2 平台特定配置

若某技能需要平台特定行为，在技能目录下创建：

```
skills/my-skill/
├── SKILL.md              # 主技能文件（通用）
├── codex.yaml           # Codex Desktop 特定配置（可选）
├── claude-code.json     # Claude Code 特定配置（可选）
├── workbuddy.json       # WorkBuddy 特定配置（可选）
├── trae.json            # Trae 特定配置（可选）
└── references/          # 引用文件（跨平台通用）
```

### 2.3 技能命名规范

| 平台 | 命名格式 | 示例 |
|:-----|:---------|:-----|
| Codex Desktop | 英文 kebab-case | `nda-review` |
| Claude Code | 英文 kebab-case | `nda-review` |
| WorkBuddy | 中文 `领域-技能名` | `商事合同法务-保密协议审查` |
| Trae | 英文 kebab-case | `nda-review` |

> 技能文件内部标识统一使用英文，WorkBuddy 的 ZIP 文件名使用中文。

---

## 3. MCP 配置规范

### 3.1 统一生成函数

```powershell
# 在 platforms.ps1 中定义
function Write-McpToPlatform {
    param(
        [PSCustomObject]$Platform,   # 来自 Get-AllPlatforms
        [string]$ServerName,
        [string]$Command,
        [string[]]$Args,
        [hashtable]$Env = @{}
    )
}
```

### 3.2 各平台 MCP 配置差异

| 特性 | Codex | Claude Code | WorkBuddy | Trae |
|:-----|:---:|:---:|:---:|:---:|
| 顶层格式 | TOML | JSON | JSON | JSON |
| Section key | `[mcp_servers.X]` | `mcpServers` | `mcpServers` | `mcpServers` |
| 需要 `type` 字段 | ❌ | ❌ | ✅ (`stdio`) | ❌ |
| 环境变量节 | `[mcp_servers.X.env]` | `env` 对象 | `env` 对象 | `env` 对象 |
| 数组语法 | `args = ["a","b"]` | `"args": ["a","b"]` | `"args": ["a","b"]` | `"args": ["a","b"]` |

---

## 4. 安装脚本规范

### 4.1 最小实现模板

```powershell
# 每个仓库的 install.ps1 必须：
param([switch]$Quick)

# 1. 加载平台框架
. "$PSScriptRoot\..\shared\platforms.ps1"

# 2. 检测平台
$platforms = Get-AllPlatforms
$active = $platforms | Where-Object { $_.Installed }

# 3. 对每个平台部署
foreach ($p in $active) {
    # 3a. 部署技能
    Deploy-SkillsToPlatform -Platform $p -SourceSkillsDir $SourceDir -SkillNamespace $Namespace

    # 3b. 生成并写入 MCP 配置
    Write-McpToPlatform -Platform $p -ServerName "my-server" -Command "python" -Args @("server.py")
}

# 4. 输出状态报告
Show-PlatformStatus
```

### 4.2 卸载脚本要求

```powershell
# uninstall.ps1 必须清理全部四个平台的残留
foreach ($p in $platforms) {
    Remove-Item (Join-Path $p.SkillsDir $SkillNamespace) -Recurse -Force -ErrorAction SilentlyContinue
    # 同时清理 MCP 配置中的对应条目
}
```

---

## 5. 目录结构规范

### 5.1 各仓库统一结构

```
repo-root/
├── AGENTS.md                    # [必需] 多平台开发准则
├── PLATFORM_SPEC.md             # [必需] 本规范文档
├── platforms.ps1                # [必需] 平台适配框架
├── install.ps1                  # [必需] 统一安装入口
├── install-codex.ps1            # Codex 平台安装器
├── install-claude-code.ps1      # Claude Code 平台安装器
├── install-workbuddy.ps1        # WorkBuddy 平台安装器
├── install-trae.ps1             # Trae 平台安装器
├── uninstall.ps1                # 卸载（四平台）
├── verify.ps1                   # 验证（四平台）
├── skills/                      # 技能源文件
│   └── {namespace}/
│       └── SKILL.md
├── mcp-configs/                 # MCP 配置模板
│   ├── codex.toml
│   ├── claude-code.json
│   ├── workbuddy.json
│   └── trae.json
└── references/                  # 跨平台引用文件
```

### 5.2 平台部署后目录

```
用户主目录/
├── .codex/
│   ├── config.toml              # MCP 配置（TOML）
│   └── skills/
│       └── {namespace}/         # 技能文件
├── .claude/
│   ├── settings.json            # MCP 配置（JSON）
│   └── plugins/
│       └── {namespace}/         # 技能文件
├── .workbuddy/
│   ├── config.json              # MCP 配置（JSON）
│   └── skills/
│       ├── {namespace}/         # 技能文件（解压版）
│       └── zip-packages/        # 技能 ZIP 包
└── .trae/
    ├── mcp.json                 # MCP 配置（JSON）
    └── skills/
        └── {namespace}/         # 技能文件
```

---

## 6. 平台接口对照表

| 接口 | Codex Desktop | Claude Code | WorkBuddy | Trae |
|:-----|:---|:---|:---|:---|
| **技能部署** | `Copy-Item → ~/.codex/skills/` | `Copy-Item → ~/.claude/plugins/` | `Copy-Item → ~/.workbuddy/skills/` + ZIP | `Copy-Item → ~/.trae/skills/` |
| **MCP 写入** | `Add-Content config.toml` | `JSON merge settings.json` | `JSON merge config.json` | `JSON merge mcp.json` |
| **环境检测** | `Test-Path ~/.codex` | `Test-Path ~/.claude/settings.json` | `Test-Path ~/.workbuddy` | `Test-Path ~/.trae` |
| **卸载清理** | 删除 skills 子目录 + TOML section | 删除 plugins 子目录 + JSON key | 删除 skills 子目录 + ZIP + JSON key | 删除 skills 子目录 + JSON key |

---

> **维护者**: laubeing-droid
> **最后更新**: 2026-05-26
