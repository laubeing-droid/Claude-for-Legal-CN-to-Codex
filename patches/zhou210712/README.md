# zhou210712 上游补丁包

## 这是啥

从 zhou210712/claude-for-legal-ZH 里抽出来的独有内容（anthropic 原版没有的）。
主要是 11 个中国法引用文件 + 中文化的 CLAUDE.md + 中国生态 MCP 连接器。

## 什么时候用

### 场景 1：检查上游有没有更新

```powershell
.\patches\zhou210712\diff-tool.ps1
```

脚本会：
1. 拉 zhou210712 最新代码到临时目录
2. 逐个比对 patches 里的 41 个文件
3. 输出结果：
   - `[✓]` 绿色 = 没变
   - `[Δ]` 黄色 = 变了
   - `[+]` 青色 = 上游新增了文件

### 场景 2：上游更新了，更新快照

先审查变更内容，确认没问题：

```powershell
.\patches\zhou210712\diff-tool.ps1 -Detailed   # 看看具体改了啥
```

确认后更新快照：

```powershell
.\patches\zhou210712\diff-tool.ps1 -Update      # 更新快照文件
```

然后去 `CHANGELOG.md` 里记一笔。

### 场景 3：本仓库装包时引用这些文件

install.ps1 已经把 zhou210712 克隆到 `~/.codex/vendor/` 了。
这些 patches 是"快照备份"，不是安装源。

## 目录有什么

| 目录 | 内容 | 文件数 |
|------|------|:------:|
| references/ | 中国法引用文件（核心资产） | 11 |
| skills/ | 中文化 CLAUDE.md 工作流 | 12 |
| connectors/ | 中国生态 MCP 连接器 | 12 |
| metadata/ | marketplace + 中文文档 | 3 |

## 快照日期

2026-05-24（基于 zhou210712 最后推送 2026-05-15）
