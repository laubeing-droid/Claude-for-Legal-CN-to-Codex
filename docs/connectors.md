# MCP 连接器配置指南

法律技能连接了权威法律数据源后效果最佳。本仓库预配置了两个中国法律数据库的 MCP 连接器：

| 连接器 | 类型 | 工具数 | 推荐度 |
|--------|------|--------|--------|
| **chineselaw（元典智库）** | stdio（npx） | 33 | ⭐ 首选 |
| **北大法宝** | HTTP | — | 备选 |

**两者选一即可**。建议优先配置 chineselaw，工具更多、配置更简单。

---

## 一、chineselaw（元典智库）— 推荐

将元典智库 API 开放平台封装为 MCP 工具，覆盖三大类共 33 个工具。

### 注册获取 API Key

1. 打开 https://open.chineselaw.com
2. 注册账号并登录
3. 进入「个人中心」→「API 管理」
4. 创建 API Key，复制保存

> **计费说明**：每次 API 调用消耗 1-10 元典平台积分，需自行充值。积分价格见平台公告。

### 配置到 Codex

方式一：使用 npx（推荐，无需安装）

安装时已自动在 `~/.codex/skills/*/.mcp.json` 中写入以下配置：

```json
{
  "mcpServers": {
    "chineselaw": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "chineselaw-mcp"],
      "env": {
        "CHINESELAW_API_KEY": "你的_API_KEY"
      },
      "title": "chineselaw（元典智库）",
      "description": "中国法律检索 — 33 个工具：法规检索、法条查询、案例检索、企业信息查询"
    }
  }
}
```

**关键步骤**：将 `CHINESELAW_API_KEY` 的值替换为你在 open.chineselaw.com 获取的真实 API Key。

方式二：本地 Python 运行

如果 Python 环境更方便，也可以下载源代码运行：

```bash
pip install mcp httpx
# 下载 server.py 到本地
python /path/to/server.py
```

对应 `.mcp.json` 配置：

```json
{
  "mcpServers": {
    "chineselaw": {
      "command": "python3",
      "args": ["/path/to/server.py"],
      "env": {
        "CHINESELAW_API_KEY": "你的_API_KEY"
      }
    }
  }
}
```

### 可用工具列表（33 个）

**法律法规（5 个）**

| 工具名 | 功能 |
|--------|------|
| `search_regulations` | 法规关键词检索与过滤 |
| `search_legal_articles` | 法条关键词检索与过滤 |
| `get_article_detail` | 获取法条详情 |
| `get_regulation_detail` | 获取法规详情 |
| `semantic_search_law` | 法律法规语义向量检索 |

**案例文书（4 个）**

| 工具名 | 功能 |
|--------|------|
| `search_cases` | 普通案例多条件检索 |
| `search_authoritative_cases` | 权威案例多条件检索 |
| `get_case_detail` | 获取案例详情 |
| `semantic_search_cases` | 案例语义向量检索 |

**企业信息（24 个）**

| 工具名 | 功能 |
|--------|------|
| `search_enterprise` | 企业名称检索 |
| `get_company_by_name` | 按名称/股票简称查企业详情 |
| `get_company_by_id` | 按 ID/信用代码查企业详情 |
| `get_enterprise_base_info` | 企业基本信息+股东+成员+分支机构 |
| `get_enterprise_investments` | 对外投资列表 |
| `get_enterprise_trademarks` | 商标列表 |
| `get_enterprise_patents` | 专利列表 |
| `get_enterprise_software_copyrights` | 软著列表 |
| `get_enterprise_works_copyrights` | 作品著作权列表 |
| `get_enterprise_icp` | 网站备案列表 |
| `get_enterprise_changes` | 工商变更记录 |
| `get_enterprise_litigation_stats` | 涉诉信息统计 |
| `get_enterprise_litigation_docs` | 涉诉文书列表 |
| `get_enterprise_court_sessions` | 开庭公告列表 |
| `get_enterprise_court_notices` | 法院公告列表 |
| `get_enterprise_dishonest` | 失信被执行人 |
| `get_enterprise_executed` | 被执行人 |
| `get_enterprise_frozen_equity` | 股权冻结 |
| `get_enterprise_penalties` | 行政处罚 |
| `get_enterprise_pledge` | 股权出质 |
| `get_enterprise_guarantees` | 对外担保 |
| `get_enterprise_abnormal_ops` | 经营异常 |
| `get_enterprise_tax_arrears` | 欠税公告 |
| `get_enterprise_serious_illegal` | 严重违法 |

### 使用示例

配置完成后，在 Codex 中直接描述法律任务即可自动调用：

```
搜索关于合同法的现行有效法规
查一下北京海淀区2023年的买卖合同纠纷案例
查询华为技术有限公司的工商信息和涉诉情况
```

---

## 二、北大法宝 — 备选方案

### 注册获取凭证

1. 打开 https://mcp.pkulaw.com
2. 注册账号并登录
3. 进入「开发者控制台」→「我的应用」
4. 创建新应用，获取 Service ID
5. 在「密钥管理」生成 Access Token
6. 在已购买的服务中复制真实的服务 URL

### 配置到 Codex

```json
{
  "mcpServers": {
    "北大法宝": {
      "type": "http",
      "url": "https://apim-gateway.pkulaw.com/YOUR_SERVICE_ID",
      "headers": {
        "Authorization": "Bearer YOUR_ACCESS_TOKEN"
      },
      "title": "北大法宝",
      "description": "中国法律法规与裁判文书检索"
    }
  }
}
```

将 `YOUR_SERVICE_ID` 和 `YOUR_ACCESS_TOKEN` 替换为真实值。

### 调试

可在 https://mcp.pkulaw.com/console/playground 实时测试 MCP 服务连接。

---

## 三、验证连接

配置完成后，重启 Codex Desktop，输入以下任一问题测试：

- **chineselaw 用户**: "搜索民法典关于合同无效的规定"
- **北大法宝用户**: "查一下最新的司法解释"

如果连接成功，技能输出中引用会标注具体来源；如果未连接，引用标注 `[需验证]`。

---

## 四、常见问题

### 连接器不生效？

1. 确认已重启 Codex Desktop
2. 确认 `.mcp.json` 中的 API Key / Token 已替换为真实值
3. 运行 `.\verify.ps1` 检查安装完整性

### 两个连接器都要配吗？

不需要。二选一即可，chineselaw 工具更丰富，推荐首选。

### 无连接器还能用吗？

可以。技能会基于模型训练数据提供分析，但引用会标注 `[需验证现行有效性]`，建议实际使用前人工核实。

### chineselaw 使用 npx 需要安装什么？

npx 是 Node.js 自带的工具，确保已安装 Node.js >= 18：
```powershell
node --version
```
如未安装，从 https://nodejs.org 下载 LTS 版本。