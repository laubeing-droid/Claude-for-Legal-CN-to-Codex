# 快速入门

60 秒完成安装，开始使用中国法律技能。

## 安装
```powershell
git clone https://github.com/laubeing-droid/codex-legal-cn-skills.git
cd codex-legal-cn-skills
.\install.ps1
```

## 验证
```powershell
Get-ChildItem "$env:USERPROFILE\.codex\skills" -Directory
```

## 开始使用
重启 Codex Desktop，直接输入：
```text
帮我审查这份 SaaS 服务协议
分析这个案件的管辖权
```

## 更新
```powershell
.\update.ps1
```

遇到问题？见 docs/troubleshooting.md
