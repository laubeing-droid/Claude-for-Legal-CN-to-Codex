# 使用指南

## 一、安装

### 前置条件

- Codex Desktop 已安装
- 操作系统：Windows 10/11
- Git（[下载](https://git-scm.com/downloads)）
- Node.js >= 18（如使用 chineselaw-mcp，[下载](https://nodejs.org)）

### 安装步骤

`powershell
git clone https://github.com/laubeing-droid/codex-legal-cn-skills.git
cd codex-legal-cn-skills
.\install.ps1
`

安装脚本自动完成：
1. 克隆上游法律内容到 ~/.codex/vendor/claude-for-legal-CN/
2. 创建 13 个技能目录和入口文件（SKILL.md）
3. 复制工作流指令（CLAUDE.md）和法律参考文件（references/）
4. 写入 MCP 连接器配置到 ~/.codex/config.toml 的 [mcp_servers] 段
5. 配置 PowerShell 执行策略
6. 验证全部技能安装成功

### 验证安装

`powershell
.\verify.ps1
`

应显示全部 13 个技能均为 [OK]。

---

## 二、配置 MCP 法律检索

法律技能连接了权威数据库后效果最佳。**二选一即可**。

### 方式一：chineselaw（推荐，33 个工具）
> 该项目基于 [chineselaw-mcp](https://www.npmjs.com/package/chineselaw-mcp)（作者 zooges）封装元典智库 API。
> 感谢原作者的开源贡献。

1. 打开 https://open.chineselaw.com，注册并获取 API Key
2. 编辑 config.toml：

   `powershell
   notepad "C:\Users\being\.codex\config.toml"
   `

3. 找到 [mcp_servers.chineselaw.env] 段，将 CHINESELAW_API_KEY 替换为真实 Key
4. 重启 Codex Desktop

### 方式二：北大法宝（10 个服务）

1. 打开 https://mcp.pkulaw.com，注册并获取 Access Token
2. 编辑 config.toml，将所有 pkulaw-* 段中的 YOUR_ACCESS_TOKEN 替换为真实 Token
3. 重启 Codex Desktop

**完整配置指南和工具列表见 docs/connectors.md**。

---

## 三、使用方式

### 自动路由（推荐）

直接在 Codex 中描述法律任务，系统自动识别并调用对应技能：

| 你说 | 路由到 |
|------|--------|
| 帮我审查这份 SaaS 服务协议 | commercial-legal |
| 分析这个案件的管辖权问题 | litigation-legal |
| 评估个人信息保护合规风险 | privacy-legal |
| 起草一份竞业限制协议 | employment-legal |
| 制定一个股权激励方案 | corporate-legal |
| 查一下这个商标能不能注册 | ip-legal |
| 搜索民法典关于合同无效的规定 | 路由到 commercial-legal，自动调用 MCP 检索 |
| 查一下华为的涉诉信息 | 路由到 corporate-legal，自动调用 MCP 检索 |

### 手动指定

如需精确控制，在对话开头使用 @技能名：

`
@codex-for-legal-cn 帮我审这份合同
@litigation-legal 分析一下证据问题
@commercial-legal/review 审查这份 NDA
`

---

## 四、自动更新

每次使用法律技能时，根技能自动执行 git pull 同步上游最新内容。无需手动操作。

如需立即同步：

`powershell
.\update.ps1
`

update.ps1 还会检查各 MCP 连接器的配置和启用状态。

---

## 五、技能清单

| 技能 | 领域 | 内容量 |
|------|------|--------|
| codex-for-legal-cn | 根技能（路由+更新） | 路由规则 + 自动更新指令 |
| commercial-legal | 商事合同 | 43KB + 12 子技能 |
| litigation-legal | 诉讼仲裁 | 28KB + 19 子技能 |
| employment-legal | 劳动用工 | 32KB + 20 子技能 |
| privacy-legal | 数据合规 | 25KB + 9 子技能 |
| corporate-legal | 公司交易 | 27KB + 13 子技能 |
| ip-legal | 知识产权 | 17KB + 12 子技能 |
| product-legal | 产品合规 | 23KB + 7 子技能 |
| regulatory-legal | 监管合规 | 10KB + 9 子技能 |
| ai-governance-legal | AI 治理 | 16KB + 10 子技能 |
| law-student | 法学生/法考 | 35KB + 13 子技能 |
| legal-clinic | 法律诊所 | 29KB + 16 子技能 |
| legal-builder-hub | 技能治理中心 | 11KB + 10 子技能 |

---

## 六、输出说明

- **定位**：所有输出均为律师审查草稿，不构成法律意见
- **引用**：已连 MCP 时标注具体来源，未连时标注 [需验证]
- **法域**：默认适用中国大陆法律，其他法域需明示

---

## 七、卸载

`powershell
.\uninstall.ps1
`

脚本会删除 ~/.codex/skills/ 下所有法律技能和 ~/.codex/vendor/ 上游缓存。
本仓库克隆文件不受影响。如需清理 config.toml 中的 MCP 条目，手动删除对应 [mcp_servers.*] 段。

---

## 八、架构概览

`
codex-legal-cn-skills        ← 本仓库（包装层）
  install.ps1                安装 + MCP 配置写入
       │
       ▼
~/.codex/config.toml         ← MCP 连接器配置
  [mcp_servers.chineselaw]
  [mcp_servers.pkulaw-*]
       │
       ▼
~/.codex/skills/<domain>/    ← 技能运行层
  SKILL.md + CLAUDE.md
       │
       ▼
~/.codex/vendor/             ← 上游法律内容缓存
`

详细架构说明见 docs/architecture.md。

---

## 九、故障排查

常见问题见 docs/troubleshooting.md。MCP 配置问题优先查看 docs/connectors.md。