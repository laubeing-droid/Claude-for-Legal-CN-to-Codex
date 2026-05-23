# 架构说明

## 四层架构

本仓库采用四层架构，将**入口定义**、**法律内容**、**运行环境**和**MCP 连接器**分离设计：

`
codex-legal-cn-skills                    ← 包装层（本仓库）
  skills/*/SKILL.md                      入口定义 + 路由规则
  install.ps1                            一键安装
  update.ps1                             手动更新
  docs/                                  文档
         │
         │ 依赖上游（自动拉取）
         ▼
~/.codex/vendor/claude-for-legal-CN/    ← 内容层（上游缓存）
  commercial-legal/
    ├── CLAUDE.md                        完整工作流指令
    ├── references/                      中国法核心规则
    └── skills/*/SKILL.md                子技能
  litigation-legal/
  employment-legal/
  ...（共 12 个领域）
         │
         │ 安装到
         ▼
~/.codex/skills/<domain>/               ← 运行层
  ├── SKILL.md                           本仓库提供（入口）
  ├── CLAUDE.md                          上游同步（主指令）
  ├── references/                        上游同步（法条参考）
  ├── skills/                            上游同步（子技能）
  └── .mcp.json                          上游同步（Codex CLI 兼容）
         │
         │ MCP 配置写入
         ▼
~/.codex/config.toml                    ← MCP 层
  [mcp_servers.chineselaw]               chineselaw-mcp（33 个工具）
  [mcp_servers.pkulaw-*]                 北大法宝（10 个服务）
`

## 各层职责

| 层级 | 内容 | 维护者 |
|------|------|--------|
| 包装层 | SKILL.md 入口定义、安装脚本、文档 | 本仓库 |
| 内容层 | CLAUDE.md 工作流指令、references 法条参考 | 上游仓库 |
| 运行层 | 技能实际执行目录 | install.ps1 自动管理 |
| MCP 层 | 法律检索连接器配置（config.toml） | install.ps1 写入 + 用户手动替换凭证 |

## 设计原则

每个技能包含两层指令：

1. **SKILL.md** —— 入口定义：做什么、何时触发、路由规则
2. **CLAUDE.md** —— 完整工作流：具体步骤、输出框架、质量标准和安全护栏

这种分离设计使得：
- 本仓库专注入口管理、平台适配和 MCP 配置
- 上游仓库专注法律内容维护
- 更新法律内容时不需要修改本仓库
- MCP 连接器独立于技能目录，统一由 config.toml 管理

## 更新流程

`
用户触发法律任务
  → 根技能 codex-for-legal-cn 激活
  → 执行 git pull 拉取上游最新内容
  → 同步 CLAUDE.md + references 到 ~/.codex/skills/
  → 检查 config.toml 中 MCP 连接器状态
  → 读取最新内容完成任务（优先调用 MCP 检索）
`

## MCP 连接器详情

### chineselaw（推荐）
> 基于 [chineselaw-mcp](https://www.npmjs.com/package/chineselaw-mcp)（作者 zooges）。
- 类型：stdio（npx chineselaw-mcp）
- 工具数：33（法规 5 + 案例 4 + 企业 24）
- 注册：https://open.chineselaw.com
- 凭证：API Key → 写入 config.toml

### 北大法宝（备选）
- 类型：HTTP（10 个独立服务）
- 覆盖：法规检索、案例检索、引证验证、案号识别、文档关联
- 注册：https://mcp.pkulaw.com
- 凭证：Access Token → 写入 config.toml

## 依赖关系

- **SH88-source/claude-for-legal-CN**（Apache 2.0）— 当前直接上游
  - 源流：anthropics/claude-for-legal（Anthropic 美国法参考）
  - 首版汉化：zhou210712/claude-for-legal-ZH

详细项目关系分析见 docs/project-analysis.md。