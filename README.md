# legal-cn

> 中国法律 AI 技能集 · Codex Desktop / Claude Code / WorkBuddy / Trae 四平台通用

覆盖商事合同、诉讼仲裁、劳动用工、数据合规、知识产权等多个法律领域的 AI 编程技能。
从法条引用到工作流指令、从 MCP 连接到护栏阻断，逐层适配中国法律体系。

## 平台支持

| 平台 | 安装方式 |
|:-----|:-----|
| **Codex Desktop** | `.\install.ps1` → 自动部署到 `~/.codex/skills/` |
| **Claude Code** | `.\install.ps1` → 自动部署到 `~/.claude/plugins/` |
| **WorkBuddy** | `.\install.ps1` → 自动部署 + 生成 ZIP 包到 `~/.workbuddy/skills/` |
| **Trae** | `.\install.ps1` → 自动部署到 `~/.trae/skills/` |

## 快速开始

```powershell
git clone https://github.com/laubeing-droid/legal-cn-main.git
cd legal-cn-main
.\install.ps1
```

安装脚本自动执行环境校验 + 安装全部依赖 + 部署到所有已检测到的平台。

## 生态项目

| 仓库 | 说明 |
|:-----|:-----|
| [legal-cn-mcp-hub](https://github.com/laubeing-droid/legal-cn-mcp-hub) | MCP 连接器中心（法规库/案例库/元典/北大法宝/飞书） |
| [legal-cn-core-codices](https://github.com/laubeing-droid/legal-cn-core-codices) | 中国法律数据库（法律全文 + 司法解释 JSON） |
| [legal-cn-judgment-predictor](https://github.com/laubeing-droid/legal-cn-judgment-predictor) | 裁判预测框架 |
| [alignment-framework](https://github.com/laubeing-droid/PRC-US-Legal-Semantic-Alignment-Framework) | 中美法律语义对齐框架 |

## 开发准则

参见 [AGENTS.md](AGENTS.md) — AI Agent 自动加载并强制执行。
