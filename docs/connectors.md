# MCP 连接器配置指南

MCP 连接器配置已独立为单独的仓库，统一管理 Codex Desktop / Claude Code / Claude Desktop 三个客户端的配置。

> **https://github.com/laubeing-droid/codex-legal-mcp-connectors**

本仓库的 `install.ps1` / `update.ps1` 会自动克隆并调用该仓库的安装/验证/更新脚本。

## 快速配置

安装本仓库后，运行：

```powershell
.\mcp-connectors\update.ps1
```

查看当前 MCP 连接器状态和凭证有效性。

如需手动编辑，配置文件路径：

| 客户端 | 配置路径 |
|--------|---------|
| Codex Desktop | `~/.codex/config.toml` |
| Claude Code | `~/.claude/settings.json` |
| Claude Desktop | `%LOCALAPPDATA%\Claude\claude_desktop_config.json` |

详细工具列表、配置步骤和常见问题请查看 MCP 连接器仓库的文档。
