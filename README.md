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
| install.ps1 | 一键安装：克隆上游、部署技能、委托 MCP 连接器安装 |
| update.ps1 | 同步上游 + 技能更新 + 委托 MCP 连接器验证/更新 |
| uninstall.ps1 | 一键卸载所有已安装技能和上游缓存 |
| verify.ps1 | 检查安装完整性 |
| skills/ | 13 个技能入口定义（SKILL.md） |
| docs/ | 完整中文文档 |
| .github/workflows/ | 上游监测 GitHub Actions |

---

## MCP 法律检索连接器

MCP 配置由独立仓库 [codex-legal-mcp-connectors](https://github.com/laubeing-droid/codex-legal-mcp-connectors) 管理，
`install.ps1` 和 `update.ps1` 均自动委托给该仓库。支持三种方式：

| 连接器 | 方式 | 工具数 | 推荐 |
|--------|------|--------|------|
| **chineselaw（元典智库）** | MCP 协议 stdio | 33 | ⭐ 首选 |
| **北大法宝 MCP 协议** | MCP 协议 HTTP | 10 服务 | 推荐 |
| **北大法宝 CLI 命令行** | CLI 工具 | — | 调试/验证 |

快速配置：编辑 `~/.codex/config.toml                   ← MCP 层（由 mcp-connectors 仓库管理）``

---

## 上游依赖链

```
anthropics/claude-for-legal → zhou210712/claude-for-legal-ZH
→ SH88-source/claude-for-legal-CN → codex-legal-cn-skills（本仓库）
```

详细项目分析见 docs/project-analysis.md。

---

## 上游监测

GitHub Actions 每周一自动检查上游链更新，仅在检测到实际变化时创建 Issue。

---

## 许可证

Apache License 2.0。

