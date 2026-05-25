<#
.SYNOPSIS
  中国法 Benchmark 统一测试运行器
.DESCRIPTION
  支持两种模式：
  - 对抗测试（默认）：验证美国法概念拦截
  - 正面测试（-Positive）：验证中国法推理正确性
.PARAMETER All
  全量模式：一次性输出所有用例
.PARAMETER Positive
  正面测试模式：运行 positive-tests.md
#>

param(
    [switch]$All,
    [switch]$Positive
)

if ($Positive) {
    $testFile = Join-Path $PSScriptRoot 'positive-tests.md'
    $modeLabel = '正面（中国法推理正确性）'
} else {
    $testFile = Join-Path $PSScriptRoot 'adversarial-tests.md'
    $modeLabel = '对抗（美国法概念拦截）'
}

if (-not (Test-Path $testFile)) {
    Write-Host "[!!] 找不到测试用例: $testFile" -ForegroundColor Red
    exit 1
}

Write-Host '========================================' -ForegroundColor Cyan
Write-Host "  中国法 Benchmark — $modeLabel" -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

$tests = @()

if ($Positive) {
    # ─── 正面测试解析 ───
    $currentCase = @{}
    foreach ($line in Get-Content $testFile -Encoding UTF8) {
        if ($line -match '^### (\d+)\. (.+)') {
            if ($currentCase.Count -gt 0 -and $currentCase.ContainsKey('查询')) {
                $tests += [PSCustomObject]$currentCase
            }
            $id = $Matches[1]
            $title = $Matches[2]
            $currentCase = @{ Id = $id; Title = $title }
            continue
        }
        if ($line -match '^\| \*\*(.+?)\*\* \| (.+?) \|$' -and $currentCase.Count -gt 0) {
            $key = $Matches[1]
            $val = $Matches[2]
            $currentCase[$key] = $val
        }
    }
    if ($currentCase.Count -gt 0 -and $currentCase.ContainsKey('查询')) {
        $tests += [PSCustomObject]$currentCase
    }
} else {
    # ─── 对抗测试解析 ───
    foreach ($line in Get-Content $testFile -Encoding UTF8) {
        if ($line -match '^\| (\d+) \| (.+?) \| (.+?) \| (.+?) \| (.+?) \|') {
            $tests += [PSCustomObject]@{
                Id       = $Matches[1]
                Query    = $Matches[2]
                Expected = $Matches[3]
                Concept  = $Matches[4]
                Severity = $Matches[5]
            }
        }
    }
}

Write-Host "共加载 $($tests.Count) 个测试用例" -ForegroundColor Yellow
Write-Host ''

if ($All) {
    Write-Host '--- 全量用例清单 ---' -ForegroundColor Cyan
    foreach ($t in $tests) {
        $sev = if ($Positive) { $t.'严重程度' } else { $t.Severity }
        $sevColor = if ($sev -match '高') { 'Red' } elseif ($sev -match '中') { 'Yellow' } else { 'Green' }
        if ($Positive) {
            Write-Host "[#$($t.Id)] $($t.Title)" -ForegroundColor $sevColor
            Write-Host "      查询: $($t.查询)"
            Write-Host "      法条: $($t.'预期法条')" -ForegroundColor DarkGray
            Write-Host "      红线: $($t.红线)" -ForegroundColor Red
        } else {
            Write-Host "[#$($t.Id)] $($t.Query)" -ForegroundColor $sevColor
            Write-Host "      预期: $($t.Expected)"
            Write-Host "      概念: $($t.Concept)"
        }
        Write-Host ''
    }
    Write-Host '--- 用例结束 ---' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '在 Codex Desktop 中逐条输入以上查询进行测试。'
} else {
    Write-Host '交互模式：按 Enter 查看下一条。' -ForegroundColor Yellow
    Write-Host ''
    $passed = 0; $failed = 0
    foreach ($t in $tests) {
        $sev = if ($Positive) { $t.'严重程度' } else { $t.Severity }
        $sevColor = if ($sev -match '高') { 'Red' } elseif ($sev -match '中') { 'Yellow' } else { 'Green' }
        Write-Host "========== 测试 #$($t.Id) ==========" -ForegroundColor Cyan
        if ($Positive) {
            Write-Host "标题:   " -NoNewline; Write-Host $t.Title -ForegroundColor $sevColor
            Write-Host "查询:   $($t.查询)"
            Write-Host "预期法条:" -ForegroundColor Green; Write-Host "  $($t.'预期法条')" -ForegroundColor DarkGray
            Write-Host "预期结论:" -ForegroundColor Green; Write-Host "  $($t.'预期结论')" -ForegroundColor DarkGray
            Write-Host "红线:   $($t.红线)" -ForegroundColor Red
        } else {
            Write-Host "查询:   " -NoNewline; Write-Host $t.Query -ForegroundColor $sevColor
            Write-Host "预期:   $($t.Expected)" -ForegroundColor Green
            Write-Host "概念:   $($t.Concept)"
        }
        Write-Host ''
        Write-Host '请在 Codex Desktop 中输入查询，然后回来报告结果。' -ForegroundColor Yellow
        Write-Host ''
        $result = Read-Host -Prompt '测试通过？(y=通过 / n=失败 / s=跳过)'
        switch ($result.ToLower()) { 'y' { $passed++ } 'n' { $failed++ } }
        Write-Host ''
    }
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '  测试完成' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    $total = $tests.Count
    $skipped = $total - $passed - $failed
    Write-Host "通过: $passed / 失败: $failed / 跳过: $skipped"
    if ($Positive) {
        Write-Host "满分: $($total * 10) 分（每个用例 10 分制）" -ForegroundColor DarkGray
    }
    if ($failed -gt 0) { Write-Host "存在未通过项，建议修复。" -ForegroundColor Red; exit 1 }
    elseif ($passed -eq $total) { Write-Host "全部通过！" -ForegroundColor Green }
}
