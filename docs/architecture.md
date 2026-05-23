# 架构说明

## 项目定位

**Claude for Legal CN to Codex** 是一个包装层项目。它不修改上游法律工作流，而是将 [SH88-source/claude-for-legal-CN](https://github.com/SH88-source/claude-for-legal-CN) 的中国法技能以 Codex Desktop 可识别的格式部署到用户环境。

## 四层架构

```
┌─────────────────────────────────────────────┐
│ 包装层  Claude-for-Legal-CN-to-Codex        │ ← 本仓库
│  skills/*/SKILL.md  install.ps1  docs/       │
│                │                              │
│                ▼                              │
│ 内容层  ~/.codex/vendor/claude-for-legal-CN/ │ ← 上游缓存（自动 git pull）
│  CLAUDE.md（工作流指令）  references（法条）    │
│                │                              │
│                ▼                              │
│ 运行层  ~/.codex/skills/<domain>/             │ ← 实际执行目录
│  SKILL.md + CLAUDE.md + references            │
│                │                              │
│                ▼                              │
│ MCP层  ~/.codex/config.toml  [mcp_servers]   │ ← 法律检索连接器
└─────────────────────────────────────────────┘
```

## 各层职责

| 层级 | 内容 | 维护者 |
|------|------|--------|
| 包装层 | SKILL.md（入口定义）、安装脚本、文档 | 本仓库 |
| 内容层 | CLAUDE.md（工作流指令）、references（法条参考） | 上游 SH88-source |
| 运行层 | skills/ 下各领域执行目录 | install.ps1 自动管理 |
| MCP 层 | chineselaw + 北大法宝连接器配置 | Codex-Claude-legal-CN-mcp-connectors |

## 设计原则

1. **两层分离**：本仓库只维护 SKILL.md（入口），工作流指令（CLAUDE.md）来自上游
2. **自动同步**：技能每次启用时自动 git pull 上游最新内容
3. **委托而非重复**：MCP 连接器管理委托给独立仓库，本仓库只负责调用
4. **原生格式**：使用 Codex Desktop 识别的 `config.toml [mcp_servers]` 格式，不使用 `.mcp.json`
5. **零额外依赖**：除 Git 和 Codex Desktop 外无其他系统依赖

## 更新流程

```
用户触发法律任务
  → 根技能 codex-claude-legal-cn 激活
    → 自动 git pull 上游 SH88-source 最新内容
      → 同步 CLAUDE.md + references 到 ~/.codex/skills/
        → 检查 config.toml MCP 状态
          → 读取最新工作流指令
            → 完成法律任务
```

## 依赖关系

- **SH88-source/claude-for-legal-CN**（Apache 2.0）— 当前直接上游
- **Codex-Claude-legal-CN-mcp-connectors**（独立仓库）— MCP 连接器管理