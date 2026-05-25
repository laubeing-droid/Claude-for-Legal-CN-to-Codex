<!--
version: 2.13.0
-->

# Codex-Claude-legal-cn-main

> 中国法律 AI 技能集 — 150+ 子技能 · Codex Desktop / Claude Code 双平台

覆盖商事合同、诉讼仲裁、劳动用工、数据合规、知识产权等 12 个法律领域 + 独立执业技能集。从法条引用到工作流指令、从 MCP 连接到护栏阻断，逐层适配中国法律体系。

## 快速开始

```powershell
git clone https://github.com/laubeing-droid/codex-claude-legal-cn-main.git
cd codex-claude-legal-cn-main
.\install.ps1
```

重启 Codex Desktop / Claude Code 即可使用。安装脚本自动拉取所有必需依赖。

## 功能全景

| 维度 | 说明 |
|:-----|:------|
| **法律领域** | 12 个（商事合同 / 诉讼仲裁 / 劳动用工 / 数据合规 / 公司交易 / 知识产权 / 产品合规 / 监管合规 / AI 治理 / 法学教育 / 法律援助 / 技能构建器） |
| **子技能** | 150+（审查合同、起草律师函、分析管辖权、评估合规风险等） |
| **护栏阻断** | 22 项美式法律概念强制拦截 + 中国法域隔离 |
| **MCP 集成** | 元典智库、北大法宝、飞书工作流 |
| **法条检索** | 162 部法律全文 JSON（通过 core-codices submodule） |

## 安装链路

运行 `install.ps1` 自动安装：
- **[必需]** `codex-claude-legal-cn-core-codices` — 162部法律全文JSON
- **[必需]** `PRC-US-Legal-Semantic-Alignment-Framework` — 中美法律语义对齐
- **[必需]** `codex-claude-legal-cn-mcp-hub` — MCP 连接器（Quick 模式）
- **[可选]** `codex-claude-legal-cn-judgment-predictor` — AI 裁判预测

所有依赖安装到同级目录，互不冲突。

## 配套项目

| 仓库 | 说明 |
|------|------|
| [core-codices](https://github.com/laubeing-droid/codex-claude-legal-cn-core-codices) | 法律数据库 — 162 部法律全文 JSON |
| [mcp-hub](https://github.com/laubeing-droid/codex-claude-legal-cn-mcp-hub) | MCP 连接器中心 — 元典/北大法宝/飞书 |
| [judgment-predictor](https://github.com/laubeing-droid/codex-claude-legal-cn-judgment-predictor) | 裁判预测框架 |
| [alignment-framework](https://github.com/laubeing-droid/PRC-US-Legal-Semantic-Alignment-Framework) | 中美法律语义对齐框架 |

## 上游来源

基于以下上游项目整合与适配：
- Anthropic [claude-for-legal](https://github.com/anthropics/claude-for-legal)
- [claude-for-legal-ZH](https://github.com/zhou210712/claude-for-legal-ZH)
- [solo-law-firm-agents](https://github.com/saysoph/solo-law-firm-agents)
- [workbuddy-cn-legal-skills](https://github.com/MAXXXXXLI/workbuddy-cn-legal-skills)

## 许可证

MIT
