# 使用指南

## 一、安装

### 前置条件
- 已安装 Codex Desktop
- 操作系统：Windows 10/11
- 已安装 Git（[下载](https://git-scm.com/downloads)）
- 网络：能访问 github.com（如在中国可能需要代理）

### 安装步骤

```powershell
# 克隆本仓库
git clone https://github.com/laubeing-droid/codex-legal-cn-skills.git
cd codex-legal-cn-skills

# 一键安装
.\install.ps1
```

安装脚本会自动完成：

1. 克隆上游法律内容仓库到 `~/.codex/vendor/claude-for-legal-CN/`
2. 创建 13 个技能目录和入口文件（SKILL.md）
3. 复制工作流指令（CLAUDE.md）和法律参考文件
4. **自动注入 MCP 连接器配置**（chineselaw + 北大法宝）到每个技能目录
5. 配置 PowerShell 执行策略
6. 验证所有技能是否安装成功

安装完成后重启 Codex Desktop 即可使用。

### 验证安装

```powershell
.\verify.ps1
```

应显示全部 13 个技能均为 `[OK]`。

---

## 二、配置 MCP 法律检索（关键步骤）

法律技能连接了权威数据库后效果最佳。本仓库预配置了两个连接器，**二选一即可**。

### 方式一：chineselaw（推荐）

33 个工具，覆盖法规检索、法条查询、案例检索、企业信息查询。

1. 打开 https://open.chineselaw.com，注册账号
2. 进入「个人中心」→「API 管理」，创建 API Key
3. 编辑 `~/.codex/skills/<任意技能目录>/.mcp.json`，找到 `chineselaw` 条目
4. 将 `CHINESELAW_API_KEY` 的值替换为你的真实 API Key
5. 重启 Codex Desktop

> 如果计算机没有安装 Node.js，请先安装 LTS 版本：https://nodejs.org

### 方式二：北大法宝

1. 打开 https://mcp.pkulaw.com，注册账号
2. 创建应用，获取 Service ID 和 Access Token
3. 编辑 `.mcp.json` 中的 `北大法宝` 条目，替换占位符
4. 重启 Codex Desktop

**详细配置指南和工具列表见 docs/connectors.md**。

---

## 三、使用方式

### 方式一：自动路由（推荐）

直接在 Codex 中描述法律工作任务：

| 你说 | 自动路由到 |
|------|-----------|
| 帮我审查这份 SaaS 服务协议 | commercial-legal |
| 分析这个案件的管辖权问题 | litigation-legal |
| 评估个人信息保护合规风险 | privacy-legal |
| 起草一份竞业限制协议 | employment-legal |
| 搜索民法典关于合同无效的规定 | commercial-legal（自动调用 chineselaw） |
| 查一下华为的涉诉信息 | corporate-legal（自动调用 chineselaw） |

### 方式二：手动指定

```
@codex-for-legal-cn 帮我审这份合同
@litigation-legal 分析一下证据问题
```

---

## 四、自动更新机制

每次使用法律技能时自动同步上游最新内容。手动更新：

```powershell
.\update.ps1
```

---

## 五、技能清单

| 技能 | 领域 | 内容 |
|------|------|------|
| codex-for-legal-cn | 根技能（路由+更新） | 路由规则、更新指令 |
| commercial-legal | 商事合同 | 合同审查、谈判、NDA 审查等 12 子技能 |
| litigation-legal | 诉讼仲裁 | 证据分析、案件管理、代理词起草等 19 子技能 |
| employment-legal | 劳动用工 | 劳动合同、竞业限制、工伤处理等 20 子技能 |
| privacy-legal | 数据合规 | 个保法合规、DPA 审查、DSAR 处理等 9 子技能 |
| corporate-legal | 公司交易 | 并购尽调、公司治理、交割检查等 13 子技能 |
| ip-legal | 知识产权 | 商标检索、专利分析、开源合规等 12 子技能 |
| product-legal | 产品合规 | 上线审查、营销审查、风险评估等 7 子技能 |
| regulatory-legal | 监管合规 | 监管动态追踪、差距分析等 9 子技能 |
| ai-governance-legal | AI 治理 | AI 政策起草、供应商审查等 10 子技能 |
| law-student | 法学生/法考 | 案例分析、论文写作、法考备考等 13 子技能 |
| legal-clinic | 法律诊所 | 接待记录、备忘录、状态报告等 16 子技能 |
| legal-builder-hub | 技能治理中心 | 技能安装、管理、QA 等 10 子技能 |

---

## 六、卸载

```powershell
.\uninstall.ps1
```

---

## 七、输出说明与注意事项

- 所有输出均为**律师审查草稿**，不构成法律意见
- 已连接检索工具：引用标注具体来源
- 未连接检索工具：引用标注 `[需验证]`
- 默认适用中国法律（大陆）

---

## 八、进阶配置

- **MCP 连接器**：参考 docs/connectors.md
- **自定义路由**：编辑 `skills/codex-for-legal-cn/SKILL.md` 的自动路由规则
- **上游监测**：GitHub Actions 每周自动检查上游更新