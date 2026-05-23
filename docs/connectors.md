# MCP 连接器配置指南

MCP 连接器配置由独立仓库维护，方便单独使用和维护：

> **https://github.com/laubeing-droid/Codex-Claude-legal-CN-mcp-connectors**

本仓库的 `install.ps1` / `update.ps1` 会自动克隆并调用该仓库的安装/更新脚本。

## 能力概览

| 连接器 | 方式 | 工具数 | 推荐 |
|--------|------|--------|------|
| **chineselaw（元典智库）** | MCP 协议 stdio | 33 | ⭐ 首选 |
| **北大法宝 MCP 协议** | MCP 协议 HTTP | 10 服务 | 推荐 |
| **北大法宝 CLI 命令行** | CLI 工具 | — | 调试/验证 |

## 快速配置

安装后编辑 config.toml：

```powershell
notepad "$env:USERPROFILE\.codex\config.toml"
```

**chineselaw（推荐）**：找到 `[mcp_servers.chineselaw.env]` → 将 `CHINESELAW_API_KEY` 替换为真实 Key
注册：https://open.chineselaw.com

**北大法宝**：找到所有 `[mcp_servers.pkulaw-*]` → 将 `YOUR_ACCESS_TOKEN` 替换为真实 Token
注册：https://mcp.pkulaw.com

详细工具列表和配置步骤请查看独立仓库的文档。
