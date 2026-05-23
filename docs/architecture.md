# 架构说明

## 项目定位

**Claude for Legal CN to Codex** 是一个包装层项目。它不重复实现法律工作流，而是将上游 [SH88-source/claude-for-legal-CN](https://github.com/SH88-source/claude-for-legal-CN) 的内容以 Codex Desktop 可识别的格式部署到用户环境。

## 四层架构

```
Claude-for-Legal-CN-to-Codex           ← 包装层（本仓库）
  skills/*/SKILL.md                     入口定义 + 路由规则
  install.ps1                           一键安装
  update.ps1                            手动更新
  docs/                                 文档
         │
         │ 依赖上游（自动拉取）
         ▼
~/.codex/vendor/claude-for-legal-CN/   ← 内容层（上游缓存）
  CLAUDE.md + references                 工作流指令 + 法条参考
         │
         │ 安装到
         ▼
~/.codex/skills/<domain>/              ← 运行层
  SKILL.md                              本仓库提供（入口）
  CLAUDE.md + references                上游同步
  skills/ + agents/                     上游同步
         │
         │ MCP 配置写入
         ▼
~/.codex/config.toml                   ← MCP 层
  [mcp_servers.chineselaw]              chineselaw-mcp（33 个工具）
  [mcp_servers.pkulaw-*]               北大法宝 MCP 协议（10 个服务）
```

## 各层职责

| 层级 | 内容 | 维护者 |
|------|------|--------|
| 包装层 | SKILL.md、安装脚本、文档 | 本仓库 |
| 内容层 | CLAUDE.md、references 法条参考 | 上游仓库（SH88-source） |
| 运行层 | 技能实际执行目录 | install.ps1 自动管理 |
| MCP 层 | 法律检索连接器配置 | Codex-Claude-legal-CN-mcp-connectors 仓库管理 |

## 设计原则

1. **两层分离**：本仓库只维护 SKILL.md（入口定义），工作流指令（CLAUDE.md）来自上游
2. **自动同步**：技能每次启用时自动 git pull 上游最新内容
3. **委托而非重复**：MCP 连接器管理委托给独立仓库，本仓库只负责调用
4. **原生格式**：使用 Codex Desktop 识别的 `config.toml [mcp_servers]` 格式，不混用 Claude Code 的 `.mcp.json`

## 更新流程

```
用户触发法律任务 → 根技能激活 → git pull 同步上游
→ 检查 config.toml MCP 状态 → 读取最新内容 → 完成
```

## 依赖关系

- **SH88-source/claude-for-legal-CN**（Apache 2.0）— 当前直接上游
  - 源流：anthropics/claude-for-legal → zhou210712/claude-for-legal-ZH → SH88-source
- **Codex-Claude-legal-CN-mcp-connectors**（独立仓库）— MCP 连接器管理
