# 常见问题排查

## 安装问题

### 安装后 Codex 没有识别技能

检查技能目录是否存在：

`powershell
Get-ChildItem "C:\Users\being\.codex\skills\"
`

应列出 13 个目录。如缺失，重新运行 .\install.ps1。

### MCP 连接器不生效（最常见问题）

Codex Desktop 的 MCP 配置在 ~/.codex/config.toml 的 [mcp_servers] 段，
**不在**技能目录的 .mcp.json 中。运行以下命令检查：

`powershell
# 查看所有 MCP 配置
Select-String "\[mcp_servers\.\w+" "C:\Users\being\.codex\config.toml"

# 或运行更新脚本自动检查
.\update.ps1
`

### 北大法宝 Token 无效

1. 确认已从 https://mcp.pkulaw.com 获取有效 Token
2. 确认 config.toml 中没有 YOUR_ACCESS_TOKEN 占位符残留
3. Token 有有效期，过期后需重新生成
4. 如需调试，使用 https://mcp.pkulaw.com/console/playground 测试连接

### chineselaw npx 相关错误

`powershell
node --version                           # 确认 Node.js 已安装（需 >= 18）
npm config set proxy http://127.0.0.1:7890   # 如在中国需配置代理
`

### git clone 失败（网络问题）

`powershell
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
`

### PowerShell 执行策略限制

`powershell
Set-ExecutionPolicy -Scope CurrentUser -RemoteSigned -Force
`

## 使用问题

### 没有自动进入法律模式

在对话开头强制指定技能名称：

`
@codex-for-legal-cn 你的问题
`

### 路由到了错误的领域

更明确地使用领域关键词，或在开头用 @技能名 指定。

### 引用标注全是 [需验证]

MCP 连接器未正确配置。按以下步骤排查：

1. 打开 config.toml，确认占位符已替换为真实凭证
2. 确认 enabled = true 存在
3. 重启 Codex Desktop
4. 详细配置指南见 docs/connectors.md

### 输出不准确

- 所有输出均为律师审查草稿，不构成法律意见
- 引用法规、案例须另行核验现行有效性
- 系统默认适用中国法律（大陆），其他法域需明示

## 更新问题

### git pull 冲突

`powershell
git stash
git pull
git stash pop
`

### 更新后技能未生效

重启 Codex Desktop。

## 路径参考

| 内容 | 所在路径 |
|------|---------|
| 技能入口文件 | ~/.codex/skills/<领域>/SKILL.md |
| 工作流指令 | ~/.codex/skills/<领域>/CLAUDE.md |
| 法律参考 | ~/.codex/skills/<领域>/references/ |
| 上游缓存 | ~/.codex/vendor/claude-for-legal-CN/ |
| MCP 连接器配置 | ~/.codex/config.toml 的 [mcp_servers] 段 |
| 本仓库克隆 | 你 clone 时的目录 |