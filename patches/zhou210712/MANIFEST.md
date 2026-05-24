# zhou210712/claude-for-legal-ZH 中国化补丁包

> 本目录从 [zhou210712/claude-for-legal-ZH](https://github.com/zhou210712/claude-for-legal-ZH) 抽取其相对于
> [anthropics/claude-for-legal](https://github.com/anthropics/claude-for-legal) 的中国法适配内容。
>
> **用途**：当 zhou210712 上游更新时，对比此快照即可定位变更内容。
> **快照日期**：2026-05-24

---

## 目录结构

`
patches/zhou210712/
├── MANIFEST.md                   本文件
├── CHANGELOG.md                  更新追踪日志
├── diff-tool.ps1                 上游比对脚本
├── references/                   中国法引用文件（11 个）
├── skills/                       中文化工作流指令（12 个）
├── connectors/                   中国生态 MCP 连接器（12 个）
└── metadata/                     平台元数据（3 个）
`

---

## 变更分类

| 类别 | 文件数 | 说明 |
|------|:------:|------|
| 核心法律引用 | 11 | 中国法原文+实务要点的独立文件。上游更新时优先关注 |
| 工作流指令 | 12 | CLAUDE.md 中文化（标题+提示+框架） |
| MCP 连接器 | 12 | 中国法律数据源工具配置（e签宝/法大大/元典/飞书） |
| 元数据 | 3 | 市场注册+文档 |

---

## 与 anthropics/claude-for-legal 对照

| 维度 | anthropics（美国法） | zhou210712（中国法） |
|------|-------------------|-------------------|
| 法律引用 | 无领域特定引用文件 | 11 个中国法引用文件 |
| MCP 连接器 | Ironclad/DocuSign/iManage | e签宝/法大大/元典/飞书 |
| 界面语言 | 英文 | 中文（标题+提示+注释） |
| 技能内容 | 2106 KB | 1486 KB（缩减 29%）|
| 工作流框架 | 美国诉讼/合同实践 | 同框架 + 中国法底层引用 |
