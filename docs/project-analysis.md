# 项目关系分析

## 一、生态总览

七个项目分布在四个平台（Claude Code、Codex、浏览器、Workbuddy），初步构成中国法律 AI 工作流的生态链。本仓库作为 Codex 平台的整合入口，将上游内容以一键安装的方式交付给中国律师。

## 二、演进路线

```
anthropics/claude-for-legal         ─  Anthropic 官方, 美国法参考
  → zhou210712/claude-for-legal-ZH  ─  中国法首次汉化
    → SH88-source/claude-for-legal-CN ─  持续维护版（本仓库直接上游）
      ├→ drdavid-kor/...-online     ─  在线网页版（浏览器）
      ├→ MAXXXXXLI/workbuddy-...    ─  豆包工作台版
      └→ gjhcsjamin/codex-for-legal-CN ─  Codex 首次封装
           └→ Claude-for-Legal-CN-to-Codex ─  本仓库（全功能整合）
```

## 三、逐项目介绍

### anthropics/claude-for-legal
- **作者**: Anthropic PBC | **平台**: Claude Code | **许可证**: Apache 2.0
- **定位**: 法律工作流参考实现（12 插件 + 5 Agent 蓝图 + 16 MCP 连接器）
- **法律基础**: 美国法
- **意义**: 整个生态的源头项目

### zhou210712/claude-for-legal-ZH
- **作者**: CSlawyer1985 / zhou210712 | **平台**: Claude Code
- **定位**: 对 Anthropic 官方版进行中国法替换的首个版本
- **核心工作**: 合同法→民法典合同编、诉讼法→民事诉讼法、劳动法→劳动合同法
- **意义**: 中国法律 AI 工作流的基础版本

### SH88-source/claude-for-legal-CN
- **作者**: SH88-source | **平台**: Claude Code
- **定位**: 在 zhou210712 基础上持续维护的中国法版本
- **意义**: 当前最活跃维护的中国法版本，本仓库的直接上游

### drdavid-kor/claude-for-legal-cn-online
- **作者**: drdavid-kor | **平台**: 浏览器（Cloudflare Workers）
- **定位**: BYOK 在线 Web 应用，无需 CLI
- **意义**: 降低使用门槛，让不熟悉终端的律师也能使用

### MAXXXXXLI/workbuddy-cn-legal-skills
- **作者**: MAXXXXXLI | **平台**: Workbuddy（豆包）
- **定位**: 151 个中文命名的技能包，覆盖 12 个法律领域
- **意义**: 将法律 AI 技能扩展到豆包工作台用户

### gjhcsjamin/codex-for-legal-CN
- **作者**: gjhcsjamin | **平台**: Codex（OpenAI CLI）
- **定位**: 首次将中国法律技能带到 Codex 平台的封装层
- **意义**: 本仓库的技术前身和灵感来源

### Claude-for-Legal-CN-to-Codex（本仓库）
- **作者**: laubeing-droid | **平台**: Codex Desktop
- **定位**: Codex 平台的全功能整合包装层
- **核心资产**:

  | 资产 | 说明 |
  |------|------|
  | 12 + 1 个 SKILL.md | 精简入口定义 + 根技能路由 |
  | install.ps1 | 一键安装（上游+技能+MCP） |
  | update.ps1 | 手动同步（5 步流程） |
  | 自动更新 | 每次使用法律功能时自动同步上游 |
  | GitHub Actions | 每周监测上游链 + npm 包更新 |
  | 全中文文档 | 使用指南、架构、项目分析等 |

## 四、关键对比

| 维度 | anthropics | zhou210712 | SH88-source | drdavid-kor | MAXXXXXLI | gjhcsjamin | **本仓库** |
|------|-----------|------------|-------------|-------------|-----------|------------|-----------|
| 目标平台 | Claude Code | Claude Code | Claude Code | 浏览器 | Workbuddy | Codex | **Codex** |
| 法律体系 | 美国法 | 中国法 | 中国法 | 中国法 | 中国法 | 中国法 | **中国法** |
| 安装方式 | 多步 | 多步 | 多步 | 打开网页 | 上传 zip | 1 步 | **1 步** |
| 自动更新 | 手动 | 手动 | 手动 | 重新部署 | 重新下载 | 手动 | **自动** |
| 文档语言 | 英文 | 中文 | 中文 | 中文 | 中文 | 中/英 | **中文** |

## 五、本仓库的定位

### 解决的问题

| 需求 | 上游状态 | 本仓库方案 |
|------|---------|-----------|
| 在 Codex 上使用中国法技能 | 需手动克隆配置 | `install.ps1` 一键安装 |
| 保持技能最新 | 各项目手动更新 | 自动 git pull + Actions 监测 |
| 中文文档 | 英文为主 | 完整中文文档体系 |
| MCP 连接器配置 | 需手动编辑 | 委托独立仓库自动管理 |

### 不涉及的范围

- 不直接修改上游的法律内容原文
- 不提供在线网页版服务
- 不跨平台转码（如转为 Workbuddy 格式）