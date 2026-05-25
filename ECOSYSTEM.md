<!--
version: 2.10.0
module: root
status: active
-->

# 四仓库生态总览

> 最后一次更新：2026-05-25

---

## 一句话关系

```
你问 Codex Desktop 一个法律问题
        │
        ▼
┌──────────────────────────────────────┐
│  CN (主技能仓库)                      │
│  理解问题 → 选领域 → 调子技能 → 输出  │
└──────┬──────────┬──────────┬─────────┘
       │          │          │
       ▼          ▼          ▼
     MCP        ALN         JDP
  (法条核验)  (概念护栏)  (裁判预测)
```

---

## 四仓库职责（互不重叠）

| 仓库 | 一句话 | 格式 | 规模 |
|:--|:--|:--|--:|
| **[CN](https://github.com/laubeing-droid/Claude-for-Legal-CN-to-Codex)** | 法律技能主仓库——12 领域 + 150+ 子技能 | SKILL.md + CLAUDE.md | ~600 文件 |
| **[MCP](https://github.com/laubeing-droid/Codex-Claude-legal-cn-mcp-hub)** | MCP 连接器中心——把北大法宝/元典/飞书接到 Codex | PS1 + Bash + Python | ~30 文件 |
| **[JDP](https://github.com/laubeing-droid/Codex-Legal-CN-Judgment-Predictor)** | 裁判预测框架——三角色对抗辩论 → 判决预测 | SKILL.md + Prompt | ~20 文件 |
| **[ALN](https://github.com/laubeing-droid/PRC-US-Legal-Semantic-Alignment-Framework)** | 中美概念对齐——美国法概念 → 中国法对应 | 映射表 + 护栏 | ~10 文件 |

---

## 调用链

```
CN 收到用户问题
    │
    ├─ 需要查法条？ → MCP (元典智库 / 北大法宝 / 国家法规库)
    ├─ 出现美国法概念？ → ALN (22 阻断概念 + 12 领域映射)
    ├─ 需要判赔多少？ → JDP (裁判预测 / 金额区间)
    └─ 本地知识库 → CN skills/references/ (语义树 + 司法解释 + 22 部 PDF)
```

---

## 上游策略（统一）

| 上游 | 关系 | 监控方式 |
|:--|:--|:--|
| anthropics/claude-for-legal | 原始框架参考 | 不追踪 |
| zhou210712/claude-for-legal-ZH | 断开，参考窗口 | GitHub Issue + diff-tool-zhou.ps1 |
| MAXXXXXLI/workbuddy-cn-legal-skills | 断开，参考窗口 | GitHub Issue + diff-tool-max.ps1 |
| saysoph/solo-law-firm-agents | 断开，参考窗口 | GitHub Issue + diff-tool-solo.ps1 |
| 中国法律官方文本 | 法条原文来源 | `gen-knowledge-index.ps1` |

> 已断开自动同步。上游有更新时发 Issue 通知，人工审查决定是否合并。

---

## CN 内部结构速查

```
skills/
├── ai-governance-legal/    # AI 治理 — 11 子技能
├── commercial-legal/       # 商事合同 — 13 子技能
├── corporate-legal/        # 公司交易 — 14 子技能
├── employment-legal/       # 劳动用工 — 21 子技能
├── ip-legal/               # 知识产权 — 12 子技能
├── law-student/            # 法学教育 — 14 子技能
├── legal-builder-hub/      # 技能构建 — 11 子技能
├── legal-clinic/           # 法律援助 — 16 子技能
├── litigation-legal/       # 诉讼仲裁 — 20 子技能
├── privacy-legal/          # 数据合规 — 9 子技能
├── product-legal/          # 产品合规 — 8 子技能
├── regulatory-legal/       # 监管合规 — 9 子技能
├── solo-law-firm/          # 独立执业 — 8 科室 27 技能
├── references/             # 共用参照：语义树 / 司法解释 / 护栏 / 输出标准
└── knowledge-base/         # 法条知识库索引
```

---

## 为什么不拆更多仓库

- 12 领域是 Codex Desktop 的加载单元，拆开会破坏插件识别
- 每个领域的 SKILL.md + CLAUDE.md + references + 子技能 是紧凑耦合
- 一个律师处理一个案件需要跨领域调用，放一个仓库是最短路径
- 四仓库之间通过 GitHub URL 引用联动，不通过代码导入

---

## 版本对照

| 仓库 | 版本 | 最后更新 |
|:--|:--|:--|
| CN | v2.10.0 | 2026-05-25 |
| MCP | v3.0.2 | 2026-05-25 |
| JDP | v1.0.1 | 2026-05-25 |
| ALN | v3.0.3 | 2026-05-25 |
