# 贡献指南

## 仓库结构

`
codex-legal-cn-skills/
  skills/<domain>/SKILL.md   入口定义（轻量，本仓库维护）
  install.ps1                一键安装脚本
  update.ps1                 更新脚本
  uninstall.ps1              卸载脚本
  verify.ps1                 安装验证脚本
  docs/                      文档
  .github/workflows/         GitHub Actions 配置
`

## 设计原则

本仓库是**包装层**，不直接包含上游法律内容。技能使用两层指令设计：

1. **SKILL.md** — 入口定义：做什么、何时使用、路由关键词
2. **CLAUDE.md** — 完整工作流（位于上游仓库）：步骤、输出框架、质量标准和护栏

## 编辑指南

### 本仓库适合修改的内容

- SKILL.md 中的路由关键词和触发规则
- 安装/更新/卸载脚本（install.ps1, update.ps1, uninstall.ps1, verify.ps1）
- MCP 连接器配置由独立仓库 codex-legal-mcp-connectors 管理。
如需修改 MCP 连接器，请直接在 mcp-connectors 仓库中操作。
如需新增或修改连接器，编辑 install.ps1 和 update.ps1 中对应的配置段。

## 提交 PR

1. 确保更改不影响现有功能
2. 更新相关文档
3. 提交 PR 到 https://github.com/laubeing-droid/codex-legal-cn-skills
