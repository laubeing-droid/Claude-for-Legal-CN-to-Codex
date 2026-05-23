# 更新日志

## [1.1.0] - 2026-05-23

### 新增
- MCP 连接器：chineselaw（元典智库）— 33 个工具，覆盖法律法规、案例、企业信息
- MCP 连接器：北大法宝 HTTP 方案（备选）
- install.ps1 / update.ps1 自动注入两个 MCP 连接器到每个技能目录
- docs/connectors.md 完整的配置指南（注册、配置、工具列表、使用示例）

### 变更
- README 更新 MCP 连接器部分，突出 chineselaw 为首选方案
- 连接器架构：install 时自动注入，不依赖上游 .mcp.json

## [1.0.1] - 2026-05-23

### 修复
- install.ps1: 修复根技能安装时目录未创建的 Bug
- install.ps1: 简化上游路径逻辑，统一使用 ~/.codex/vendor/claude-for-legal-CN
- update.ps1: 修复转义字符错误，重构路径逻辑
- SKILL.md: 统一 12 个领域技能的 description 和 keywords 格式

### 新增
- uninstall.ps1: 一键卸载所有已安装技能和上游缓存
- verify.ps1: 安装后完整性检查脚本
- .gitattributes: 统一行尾符号（LF），消除 git 警告
- .gitignore: 完善忽略规则

### 改进
- GitHub Actions: 增加 commit SHA 缓存，仅在有实际更新时创建 Issue

## [1.0.0] - 2026-05-23

### 新增
- 13 个 Codex 技能（1 根技能 + 12 领域技能）
- 自动路由 + 自动更新 + 上游监测 Actions
- install.ps1 / update.ps1
- 全套中文文档