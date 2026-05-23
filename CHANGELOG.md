# 更新日志

## [2.2.1] - 2026-05-23

### 代码修复
- install.ps1 / update.ps1: 删除 .mcp.json 复制行（Claude Code 格式，Codex 不识别）

## [2.2.0] - 2026-05-23

### 品牌重命名
- GitHub 仓库从 `codex-legal-cn-skills` 重命名为 `Claude-for-Legal-CN-to-Codex`
- 所有文档和脚本中的显示名称同步更新

## [2.1.0] - 2026-05-23

### MCP 连接器委托改造
- update.ps1: 步骤 3/4 从硬编码 MCP 检查改为委托 mcp-connectors 仓库
- README.md / QUICKSTART.md: 更新 MCP 相关描述

## [2.0.0] - 2026-05-23

### MCP 连接器独立仓库
- MCP 配置逻辑迁移到 https://github.com/laubeing-droid/Codex-Claude-legal-CN-mcp-connectors
- install.ps1: 步骤 3 改为克隆并运行 mcp-connectors/install.ps1

## [1.4.0] - 2026-05-23

### 功能增强
- update.ps1 新增 5 步流程：更新上游 → 同步技能 → MCP 检查 → MCP 更新 → 验证

## [1.3.1] - 2026-05-23

### 文档优化
- docs/connectors.md: 简化，指向独立仓库

## [1.3.0] - 2026-05-23

### 北大法宝拆分
- 明确分为 MCP 协议（10 服务）和 CLI 命令行两类

## [1.2.1] - 2026-05-23

### 修复
- MCP 架构修复

## [1.2.0] - 2026-05-23

### MCP 架构整改
- 改用 config.toml 写入，废弃 .mcp.json 方式

## [1.1.0] - 2026-05-23

### MCP 集成
- 集成 chineselaw-mcp（33 工具）和北大法宝 MCP

## [1.0.1] - 2026-05-23

### 修复与改进
- 修复安装脚本问题
- 完善文档体系

## [1.0.0] - 2026-05-23

### 初始发布
- 首个可用版本
