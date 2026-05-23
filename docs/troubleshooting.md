# 常见问题排查

## 安装问题

### 安装后 Codex 没识别
检查 ~/.codex/skills/ 目录，重跑 install.ps1

### git clone 失败
```powershell
git config --global http.proxy http://127.0.0.1:7890
```

### 执行策略错误
```powershell
Set-ExecutionPolicy -Scope CurrentUser -RemoteSigned -Force
```

## 使用问题
### 没进入法律模式
强制指定：@codex-for-legal-cn 你的问题

### 输出不准确
所有输出均为草稿，引用须核验现行有效性。

## 更新问题
### git pull 冲突
```powershell
git stash && git pull && git stash pop
```
