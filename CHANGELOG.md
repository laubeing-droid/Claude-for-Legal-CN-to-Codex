# 更新日志

## [1.2.1] - 2026-05-23

### 文档全面重写
- 全站文档修正 MCP 配置路径（.mcp.json → config.toml）
- README.md：MCP 部分改为 config.toml 说明，架构图补充 MCP 层
- QUICKSTART.md：新增 MCP 配置步骤
- docs/architecture.md：重写为四层架构，新增 MCP 层说明
- docs/connectors.md：补充 chineselaw 工具列表，完善排查方法
- docs/usage-guide.md：统一格式，补充架构概览
- docs/troubleshooting.md：补充 MCP 诊断命令
- docs/contributing.md：补充 MCP 修改指南

## [1.2.0] - 2026-05-23

### 重要变更
- MCP 配置从 .mcp.json 改为 ~/.codex/config.toml 的 [mcp_servers] 段
- 新增 chineselaw-mcp（33 工具） + 北大法宝（10 服务）
- install.ps1：智能追加 config.toml，不覆盖已有配置
- update.ps1：MCP 状态检查

## [1.1.0] - 2026-05-23

### 新增
- MCP 连接器：chineselaw + 北大法宝

## [1.0.1] - 2026-05-23

### 修复
- install.ps1 根技能目录 Bug
- update.ps1 转义错误
- SKILL.md 格式统一
- 新增 uninstall.ps1, verify.ps1, .gitattributes

## [1.0.0] - 2026-05-23

### 新增
- 13 个 Codex 技能，自动路由 + 自动更新，全套中文文档