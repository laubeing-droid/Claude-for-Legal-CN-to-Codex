# Codex 中国法律技能包

面向中国律师的 Codex 法律工作技能集。覆盖诉讼仲裁、商事合同、劳动用工、
数据合规、知识产权等 12 个核心法律领域，安装即用、自动更新。

> **新用户？** 从 QUICKSTART.md 开始 —— 60 秒完成安装。本文档是完整参考手册。

---

## 快速安装

```powershell
git clone https://github.com/laubeing-droid/codex-legal-cn-skills.git
cd codex-legal-cn-skills
.\install.ps1
```

重启 Codex Desktop，直接描述法律任务即可自动启用。

---

> **重要声明**
> 所有技能输出均为律师审查草稿，不构成法律意见，不能替代律师。
> 引用法规须核验现行有效性，提交/发送前需经执业律师审核。

---

## 仓库内容

| 文件 | 说明 |
|------|------|
| install.ps1 | 一键安装：克隆上游、部署技能、写入 MCP 配置到 config.toml |
| update.ps1 | 手动同步上游最新内容 + 检查 MCP 状态 |
| uninstall.ps1 | 一键卸载所有已安装技能和上游缓存 |
| verify.ps1 | 检查安装完整性 |
| skills/ | 13 个技能入口定义（SKILL.md） |
| docs/ | 完整中文文档 |
| .github/workflows/ | 上游监测 GitHub Actions |

---

## MCP 法律检索连接器

法律技能连接了权威数据源后效果最佳。安装脚本自动在 `~/.codex/config.toml` 中写入两组 MCP 配置：

### chineselaw（推荐）
> 基于 [chineselaw-mcp](https://www.npmjs.com/package/chineselaw-mcp)（作者 zooges）封装。

33 个工具，覆盖法规检索、案例检索、企业信息查询。

**配置方式**：注册 https://open.chineselaw.com → 获取 API Key → 编辑 `config.toml`，将 `[mcp_servers.chineselaw.env]` 中的 `CHINESELAW_API_KEY` 替换为真实 Key。

### 北大法宝（备选）

10 个独立 MCP 服务，覆盖法规检索、案例检索、引证验证、案号识别等。

**配置方式**：注册 https://mcp.pkulaw.com → 获取 Access Token → 编辑 `config.toml`，将所有 `pkulaw-*` 条目中的 `YOUR_ACCESS_TOKEN` 替换为真实 Token。

> **二选一即可**，不需要两个都配。完整指南见 docs/connectors.md。

---

## 技能清单

| skill | area | size |
|-------|------|------|
| codex-for-legal-cn | 根技能（路由+更新） | - |
| commercial-legal | 商事合同 | 43KB + 12 sub-skills |
| litigation-legal | 诉讼仲裁 | 28KB + 19 sub-skills |
| employment-legal | 劳动用工 | 32KB + 20 sub-skills |
| privacy-legal | 数据合规 | 25KB + 9 sub-skills |
| corporate-legal | 公司交易 | 27KB + 13 sub-skills |
| ip-legal | 知识产权 | 17KB + 12 sub-skills |
| product-legal | 产品合规 | 23KB + 7 sub-skills |
| regulatory-legal | 监管合规 | 10KB + 9 sub-skills |
| ai-governance-legal | AI 治理 | 16KB + 10 sub-skills |
| law-student | 法学生/法考 | 35KB + 13 sub-skills |
| legal-clinic | 法律诊所 | 29KB + 16 sub-skills |
| legal-builder-hub | 技能治理中心 | 11KB + 10 sub-skills |

## 自动路由

| 你说 | 路由到 |
|------|--------|
| 帮我审查这份 SaaS 服务协议 | commercial-legal |
| 分析这个案件的管辖权问题 | litigation-legal |
| 评估个人信息保护合规风险 | privacy-legal |
| 起草一份竞业限制协议 | employment-legal |
| 做个并购尽调问题清单 | corporate-legal |
| 查一下这个商标能不能注册 | ip-legal |
| 检查这个产品上线合规性 | product-legal |
| 追踪最近三个月的监管动态 | regulatory-legal |
| 评估这个 AI 产品的法律风险 | ai-governance-legal |
| 帮我分析这个法考案例 | law-student |
| 法律援助接谈记录 | legal-clinic |

也可手动指定：

```
@codex-for-legal-cn 帮我审这份合同
@litigation-legal 分析一下证据问题
```

---

## 自动更新机制

每次触发法律任务时，根技能自动执行：
1. 查找上游缓存 `~/.codex/vendor/claude-for-legal-CN/`
2. git pull 拉取上游最新内容
3. 同步 CLAUDE.md + references 到 `~/.codex/skills/`
4. 本次对话直接生效，无需重启

手动更新：

```powershell
.\update.ps1
```

---

## 架构

本仓库采用四层架构：

```
codex-legal-cn-skills                  ← 包装层（本仓库）
  skills/SKILL.md                      入口定义 + 路由规则
  install.ps1 / update.ps1             安装与更新
  docs/                                文档
       |
       | 依赖上游
       v
~/.codex/vendor/claude-for-legal-CN/   ← 内容层（自动缓存）
  CLAUDE.md + references                完整工作流指令 + 中国法核心规则
       |
       | 安装到
       v
~/.codex/skills/<domain>/              ← 运行层
  SKILL.md                              本仓库提供（入口）
  CLAUDE.md + references                上游同步（主指令 + 法条参考）
  skills/ + agents/                     上游同步（子技能）
       |
       | MCP 连接器写入
       v
~/.codex/config.toml                   ← MCP 层
  [mcp_servers.chineselaw]              chineselaw-mcp（33 个工具）
  [mcp_servers.pkulaw-*]                北大法宝（10 个服务）
```

### 设计原则

每个技能包含两层指令：
- **SKILL.md** —— 入口定义：做什么、何时触发、路由规则
- **CLAUDE.md** —— 完整工作流：步骤、输出框架、质量标准和安全护栏

---

## 上游依赖链

```
anthropics/claude-for-legal            <- 美国法原版（Anthropic 官方）
  | fork + 全面汉化
  v
zhou210712/claude-for-legal-ZH         <- 中文汉化版
  | 持续维护
  v
SH88-source/claude-for-legal-CN        <- 当前直接上游
  | 本仓库整合包装
  v
codex-legal-cn-skills                  <- 你在这里
```

详细项目分析见 docs/project-analysis.md。

---

## 上游监测

GitHub Actions 每周一自动检查上游链更新，仅在检测到实际变化时创建 Issue。

---

## 许可证

Apache License 2.0。