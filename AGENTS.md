# AGENTS.md — laubeing-droid 多平台开发准则

> 本文件适用于 [laubeing-droid](https://github.com/laubeing-droid) 旗下全部仓库。
> 当你（AI Agent）处理该仓库的任何文件时，必须遵守以下准则。

---

## 一、核心准则：四平台兼容

本仓库的**所有代码、配置、技能、安装脚本**必须兼容以下四种 AI 编程平台：

| # | 平台 | 厂商 | 配置格式 | 技能路径 | MCP 格式 |
|:--|:-----|:-----|:---------|:---------|:---------|
| 1 | **Codex Desktop** | OpenAI | TOML | `~/.codex/skills/` | TOML `[mcp_servers.X]` |
| 2 | **Claude Code** | Anthropic | JSON | `~/.claude/plugins/` | JSON `mcpServers` |
| 3 | **WorkBuddy** | Tencent | JSON | `~/.workbuddy/skills/` | JSON `mcpServers` + ZIP 包 |
| 4 | **Trae** | ByteDance | JSON | `~/.trae/skills/` | JSON `mcpServers` |

**规则：任何一个平台的接口缺失 = Bug，必须修复。**

---

## 二、平台接口要求

### 2.1 技能文件（SKILL.md）

每个 SKILL.md 必须包含以下 frontmatter，确保四平台可识别：

```yaml
---
name: skill-name              # 英文标识（跨平台通用）
description: ...              # 中文描述
platforms: [codex, claude-code, workbuddy, trae]  # 必填
version: x.y.z
---
```

- `platforms` 字段声明该技能支持哪些平台
- 每个平台若需特殊配置，在同目录下创建 `codex.yaml` / `claude-code.json` / `workbuddy.json` / `trae.json`

### 2.2 安装脚本（install.ps1 / install.sh）

**强制规则**：
1. 安装脚本必须检测所有四个平台（参考 `platforms.ps1`）
2. 对已安装的平台，自动部署对应的技能文件/MCP配置
3. 平台检测函数：`Get-AllPlatforms`（从 `platforms.ps1` 加载）
4. 平台特定配置统一使用 `Write-McpToPlatform` 函数

**安装脚本最小模板**：
```powershell
# 加载平台适配框架
. "$PSScriptRoot\..\platforms.ps1"  # 或从独立路径加载

$platforms = Get-AllPlatforms
$active = $platforms | Where-Object { $_.Installed }

foreach ($p in $active) {
    switch ($p.Id) {
        'codex'        { Deploy-ToCodex $p }
        'claude-code'  { Deploy-ToClaudeCode $p }
        'workbuddy'    { Deploy-ToWorkBuddy $p }
        'trae'         { Deploy-ToTrae $p }
    }
}
```

### 2.3 MCP 连接器配置

每个 MCP Server 必须生成四种格式的配置：

| 平台 | 函数 | 配置示例 |
|:-----|:-----|:---------|
| Codex Desktop | `New-CodexMcpConfig` | `[mcp_servers.SERVER]` + `command = "..."` |
| Claude Code | `New-ClaudeMcpConfig` | `{"mcpServers": {"SERVER": {"command": "..."}}}` |
| WorkBuddy | `New-WorkBuddyMcpConfig` | `{"mcpServers": {"SERVER": {"command": "...", "type": "stdio"}}}` |
| Trae | `New-TraeMcpConfig` | `{"mcpServers": {"SERVER": {"command": "..."}}}` |

### 2.4 WorkBuddy 特殊要求

- 每技能独立打包为 ZIP（格式：`{领域}-{技能名}.zip`）
- ZIP 内必须包含 `SKILL.md` + `references/` 目录
- 同时部署解压版和 ZIP 版到 `~/.workbuddy/skills/`

### 2.5 Trae 特殊要求

- Trae 基于 VS Code 架构，配置文件在 `~/.trae/` 目录
- macOS 上可能在 `~/Library/Application Support/Trae/`
- MCP 配置使用 JSON 格式（与 Claude Code 相同）
- 技能部署为 VS Code 扩展兼容格式

---

## 三、仓库特定准则

### 3.1 codex-claude-legal-cn-main（技能主仓库）

- **所有 150+ 子技能**的 SKILL.md 必须声明 `platforms` 字段
- `install.ps1` 必须部署到全部四个平台的技能目录
- 新增技能时同时生成四平台配置
- 护栏/阻断规则（29项）四平台通用，但需确认 WorkBuddy 和 Trae 的加载路径

### 3.2 codex-claude-legal-cn-mcp-hub（MCP 连接器）

- `detect.ps1` 必须检测全部四个平台
- 每个连接器的 `install-*` 函数必须输出四种 MCP 配置
- `verify.ps1` 必须验证四种平台配置的正确性
- Python MCP Server 代码不受影响（平台无关），仅配置生成需要四路输出

### 3.3 codex-claude-legal-cn-core-codices（法律数据库）

- 本仓库是数据层，平台无关
- 但 `install.ps1` 必须确保数据 JSON 能被所有四个平台访问
- 符号链接策略：在四个平台的技能目录下创建指向数据的符号链接

### 3.4 PRC-US-Legal-Semantic-Alignment-Framework（语义对齐）

- 框架文档是平台无关的纯文本
- 但 `install.ps1` 必须将框架注入到所有四个平台的 System Prompt / 知识库路径
- 对齐映射表的 JSON 版本需放在可被四平台共同访问的位置

### 3.5 codex-claude-legal-cn-judgment-predictor（裁判预测）

- `SKILL.md` 的 `platforms` 字段必填
- Prompt 文件（plaintiff/defendant/judge）平台无关
- `install.ps1` 部署到全部四个平台
- MCP 连接（类案检索）需确保四平台都可调用

---

## 四、开发流程

### 4.1 新增功能 Checklist

- [ ] 是否在全部四个平台测试了接口？
- [ ] SKILL.md 是否声明了 `platforms: [codex, claude-code, workbuddy, trae]`？
- [ ] install.ps1 是否对全部四个平台有部署逻辑？
- [ ] MCP 配置是否生成了全部四种格式？
- [ ] WorkBuddy ZIP 包是否正确生成？
- [ ] Trae 的配置路径是否正确（Windows/macOS 双平台）？

### 4.2 不允许的做法

- ❌ 只写 Codex Desktop 的 TOML 配置
- ❌ 硬编码 `~/.codex/skills/` 路径
- ❌ 假设用户只使用一个平台
- ❌ SKILL.md 缺少 `platforms` 字段
- ❌ MCP 配置只输出 JSON 或只输出 TOML

### 4.3 正确做法示例

```powershell
# ✅ 正确：同时为全部平台配置
function Install-McpServer {
    $platforms = Get-AllPlatforms | Where-Object { $_.Installed }
    foreach ($p in $platforms) {
        Write-McpToPlatform -Platform $p -ServerName "my-server" -Command "python" -Args @("server.py")
    }
}

# ❌ 错误：只配置 Codex
function Install-McpServer-WRONG {
    $codexConfig = "$env:USERPROFILE\.codex\config.toml"
    Add-Content $codexConfig "[mcp_servers.my-server]`ncommand = `"python`""
}
```

---

## 五、平台检测优先级

当四个平台同时安装时，按以下优先级处理冲突：

1. **Codex Desktop** — 主开发平台，优先测试
2. **Claude Code** — 格式与 Trae 相似，合并测试
3. **WorkBuddy** — ZIP 打包逻辑独立
4. **Trae** — 与 Claude Code JSON 格式兼容

## 六、测试要求

- 新功能提交前，必须至少在 **Codex Desktop** 上验证通过
- MCP 配置变更必须在 **Codex + Claude Code** 上验证
- WorkBuddy ZIP 生成可在无 WorkBuddy 环境下仅验证 ZIP 结构
- Trae 配置可在无 Trae 环境下仅验证 JSON 格式

---

> **最后更新**：2026-05-26
> **适用仓库**：laubeing-droid 全部
> **强制执行**：是（违反本准则的代码不得合并）

---

## 七、环境一致性校验（强制）

### 7.1 原则

**Python 3.9 在公司能跑、在家就炸** —— 这是典型的"环境不一致"问题。本仓库的 MCP Server 依赖 `mcp>=1.0.0`（需要 Python 3.10+），`pydantic>=2.0.0`（与 v1 不兼容），`httpx>=0.27.0`。依赖链中任何一个版本漂移都会导致：

| 场景 | 表象 | 根因 |
|:-----|:-----|:-----|
| Python 3.9 | `import mcp` → SyntaxError (match/case) | mcp 需要 3.10+ |
| pydantic v1 | `from pydantic import BaseModel` → AttributeError | v2 API 不兼容 v1 |
| httpx 0.26 | AsyncClient 方法签名变化 | 0.27 breaking changes |
| Node.js 缺失 | 飞书连接器静默失败 | npm MCP 无法启动 |

**规则：install.ps1 的第一步必须是调用 `env-check.ps1`。阻断项存在时禁止继续安装。**

### 7.2 安装脚本集成

```powershell
# 每个 install.ps1 必须在开头加入：
$envCheck = Join-Path $PSScriptRoot "env-check.ps1"
if (Test-Path $envCheck) {
    & $envCheck
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Environment check failed. Fix issues above and re-run." -ForegroundColor Red
        exit 1
    }
}
```

### 7.3 校验项目总表

| # | 检查项 | 最低要求 | 不满足后果 | 等级 |
|:--|:-----|:-----|:-----|:--|
| 1 | PowerShell | >=5.1 | 脚本语法错误 | 🔴 CRITICAL |
| 2 | Python | >=3.10 | mcp SDK 无法运行 | 🔴 CRITICAL |
| 3 | pip | 可用 | 无法安装 Python 包 | 🔴 CRITICAL |
| 4 | Git | 可用 | 无法克隆依赖仓库 | 🔴 CRITICAL |
| 5 | GitHub 可达 | 网络通 | 无法下载仓库 | 🔴 CRITICAL |
| 6 | PyPI 可达 | 网络通 | 无法安装 pip 包 | 🔴 CRITICAL |
| 7 | mcp 包 | >=1.0.0 | MCP Server 启动失败 | 🟡 WARNING |
| 8 | httpx 包 | >=0.27.0 | API 调用异常 | 🟡 WARNING |
| 9 | pydantic 包 | >=2.0.0 (非 v1) | server.py 崩溃 | 🔴 CRITICAL |
| 10 | Node.js | >=18.0 | 飞书连接器不可用 | 🟡 WARNING |
| 11 | 磁盘空间 | >=1 GB | 无法克隆仓库 | 🔴 CRITICAL |
| 12 | 平台检测 | 至少一个 | 没有部署目标 | 🟡 WARNING |

### 7.4 用户修复指引

校验失败时，输出精确的修复命令（而非笼统的"请升级 Python"）：

```
[X] [Python] Python 3.9 — mcp SDK requires >=3.10
     fix: winget install Python.Python.3.12

[X] [Pkg] pydantic v1 detected! v2 API incompatible
     fix: pip uninstall pydantic -y; pip install 'pydantic>=2.0.0'
```
