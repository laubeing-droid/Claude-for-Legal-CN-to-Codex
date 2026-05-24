# MAXXXXXLI/workbuddy-cn-legal-skills 中国化补丁包

> 本目录从 [MAXXXXXLI/workbuddy-cn-legal-skills](https://github.com/MAXXXXXLI/workbuddy-cn-legal-skills) 抽取其相对于
> [anthropics/claude-for-legal](https://github.com/anthropics/claude-for-legal) 的中国法适配内容。
>
> **用途**：当 MAXXXXXLI 上游更新时，对比此快照即可定位变更内容。
> **快照日期**：2026-05-24

---

## 目录结构

`
patches/maxxxxxli/
├── MANIFEST.md                        本文件
├── CHANGELOG.md                       更新追踪日志
├── README.md                          快速上手指南
├── diff-tool.ps1                      上游比对脚本
├── references/
│   ├── china-legal-context.md         全局法源指引（5.5 KB）
│   ├── china-context-商事合同法务.md    模块级中国语境（13 个模块）
│   ├── china-context-争议解决法务.md
│   └── ...（共 14 个文件）
├── metadata/
│   ├── NOTICE                         改编来源说明
│   └── README.md                      原仓库说明
└── skills-index/
    └── skills-manifest.csv            151 个技能中英文对照表
`

---

## 变更分类

| 类别 | 文件数 | 说明 |
|------|:------:|------|
| 全局法源指引 | 1 | china-legal-context.md — 官方来源汇总 + 13 个基准链接 |
| 模块语境 | 13 | 每个领域一份 china-context.md — 中国法实务提示 |
| 元数据 | 2 | NOTICE 来源声明 + README 说明 |
| 技能索引 | 1 | 151 个技能的中文名 ↔ 英文领域对照 |

---

## 与 anthropics/claude-for-legal 对照

| 维度 | anthropics（美国法） | MAXXXXXLI（中国法） |
|------|-------------------|-------------------|
| 平台 | Claude Code | WorkBuddy（豆包） |
| 适配方式 | — | 原文保留 + 中国语境覆盖层 |
| 中国法内容 | 无 | 1 个全局指引 + 13 个模块语境 |
| 技能数量 | 150 子技能 | 151 个独立 ZIP |
| 原文质量 | — | 完整保留（不删不改） |
| 风险提示 | 标准 disclaimer | 增强版 + [需核验] 标签 |
