# MCP 连接器

本仓库的 MCP 连接器配置委托给独立仓库管理。

> **Codex-Claude-legal-CN-mcp-connectors**
> https://github.com/laubeing-droid/Codex-Claude-legal-CN-mcp-connectors

`install.ps1` 和 `update.ps1` 会自动克隆并调用该仓库的安装/更新脚本。

## 连接器概览

| 连接器 | 方式 | 工具数 | 推荐 |
|--------|------|--------|------|
| **chineselaw（元典智库）** | stdio | 33 | ⭐ 首选 |
| **北大法宝 MCP 协议** | HTTP | 10 服务 | 推荐 |
| **北大法宝 CLI** | 命令行 | — | 调试/验证 |

## 快速配置

```powershell
notepad "$env:USERPROFILE\.codex\config.toml"
```

- **chineselaw**：替换 `CHINESELAW_API_KEY`（注册：https://open.chineselaw.com）
- **北大法宝**：替换所有 `YOUR_ACCESS_TOKEN`（注册：https://mcp.pkulaw.com）

详细配置指南和工具列表请查看独立仓库的文档。