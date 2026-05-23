# 常见问题排查

## 安装问题

### 安装后 Codex 没有识别技能

```powershell
Get-ChildItem "$env:USERPROFILE\.codex\skills\"
```

应列出 13 个目录。如缺失，重新运行 `.\install.ps1`。

### MCP 连接器不生效

Codex Desktop 的 MCP 配置在 `~/.codex/config.toml`，**不在** `.mcp.json` 中。

```powershell
# 查看所有 MCP 配置
Select-String "\[mcp_servers\.\w+" "$env:USERPROFILE\.codex\config.toml"

# 运行更新脚本自动检查
.\update.ps1
```

### chineselaw npx 错误

```powershell
node --version                         # 需 >= 18
npm config set proxy http://127.0.0.1:7890  # 如网络受限
```

### git clone 失败

```powershell
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

### PowerShell 执行策略限制

```powershell
Set-ExecutionPolicy -Scope CurrentUser -RemoteSigned -Force
```

## 使用问题

### 没有自动进入法律模式

```
@codex-claude-legal-cn 你的问题
```

### 引用标注全是 [需验证]

MCP 连接器未正确配置。按以下步骤排查：
1. 打开 config.toml，确认占位符已替换为真实凭证
2. 确认 `enabled = true` 存在
3. 重启 Codex Desktop
4. 运行 `.\update.ps1` 查看 MCP 状态
5. 详细配置指南见 [MCP 连接器仓库](https://github.com/laubeing-droid/Codex-Claude-legal-CN-mcp-connectors)

### 输出不准确

- 所有输出均为律师审查草稿
- 引用法规、案例须核验现行有效性
- 默认适用中国大陆法律，其他法域需明示

## 更新问题

```powershell
git stash && git pull && git stash pop   # 解决冲突
.\update.ps1                              # 手动更新
```

## 路径参考

| 内容 | 路径 |
|------|------|
| 技能入口 | `~/.codex/skills/<领域>/SKILL.md` |
| 工作流指令 | `~/.codex/skills/<领域>/CLAUDE.md` |
| 法律参考 | `~/.codex/skills/<领域>/references/` |
| 上游缓存 | `~/.codex/vendor/claude-for-legal-CN/` |
| MCP 配置 | `~/.codex/config.toml` 的 `[mcp_servers]` 段 |
| 本仓库 | clone 时的目录 |
