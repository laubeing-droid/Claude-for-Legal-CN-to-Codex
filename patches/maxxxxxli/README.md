# MAXXXXXLI 上游补丁包

## 这是啥

从 [MAXXXXXLI/workbuddy-cn-legal-skills](https://github.com/MAXXXXXLI/workbuddy-cn-legal-skills) 里抽出来的独有内容（anthropic 原版没有的）。

MAXXXXXLI 做的中国化适配方式是：
- 保留 anthropic 原文不动
- 在 SKILL.md 头部加"中国语境适配"声明
- 新增 china-legal-context.md（全局法源指引）+ 每个领域 china-context.md

这里存的就是那些**新增的中国语境文件**。

## 什么时候用

### 检查上游有没有更新

`powershell
.\patches\maxxxxxli\diff-tool.ps1
`

脚本会：
1. 拉 MAXXXXXLI 最新代码到临时目录
2. 解压 ZIP，提取语境文件
3. 逐个比对 patches 里的文件
4. 输出结果

### 上游更新了，更新快照

先看改了啥：

`powershell
.\patches\maxxxxxli\diff-tool.ps1 -Detailed
`

确认后更新：

`powershell
.\patches\maxxxxxli\diff-tool.ps1 -Update
`

然后去 CHANGELOG.md 里记一笔。

## 目录有什么

| 目录 | 内容 |
|------|------|
| references/ | china-legal-context.md（全局法源指引）+ 13 个模块语境 |
| metadata/ | NOTICE（来源声明）+ README（原仓库说明） |
| skills-index/ | 151 个技能中英文对照表 |

## 快照日期

2026-05-24
