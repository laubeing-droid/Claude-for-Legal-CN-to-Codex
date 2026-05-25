# Legal Retrieval Router — 本地优先→MCP→浏览器三级降级
# 用法: .\patches\legal-retrieval-router.ps1 "民法典第153条"
param(
    [Parameter(Mandatory=$true)]
    [string]$Query,
    [switch]$Detailed,
    [switch]$LocalOnly
)

$REPO = Resolve-Path (Join-Path $PSScriptRoot "..")
$LAW_TREE = Join-Path $REPO "skills\references\law-semantic-tree.json"
$JUDICIAL_TREE = Join-Path $REPO "skills\references\judicial-interpretations.json"
$REGULATORY_TREE = Join-Path $REPO "skills\references\regulatory-compliance-tree.json"
$CONFIG_FILE = Join-Path $REPO "skills\references\retrieval-config.json"

function Write-Step { param($msg) if ($Detailed) { Write-Host $msg -ForegroundColor Yellow } }

Write-Host ""
Write-Host "=== 法律检索路由器 ===" -ForegroundColor Cyan
Write-Host "查询: $Query"
Write-Host ""

# ============================================================
# Layer 1: 本地搜索
# ============================================================
Write-Step "[Layer 1] 搜索本地语义树..."

$results = @()
$tokens = $Query -split '\s+' | Where-Object { $_.Length -gt 0 }
$articleMatch = $null
$lawMatch = $null
foreach ($t in $tokens) {
    if ($t -match '第?\d+条' -or $t -match '^(一|二|三|四|五|六|七|八|九|十)\d*$') { $articleMatch = $t }
    if ($t -match '民法典|刑法|公司法|劳动|合同|数据|个保|民诉|反不正当|广告|消保|行政') { $lawMatch = $t }
}

# 1a. 搜索 law-semantic-tree.json
try {
    $lawTree = Get-Content $LAW_TREE -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($lawProp in $lawTree.laws.PSObject.Properties) {
        $lawName = $lawProp.Name
        $lawData = $lawProp.Value
        if ($lawMatch -and $lawName -notmatch $lawMatch) { continue }
        
        foreach ($article in $lawData.articles) {
            $matched = $false
            if ($articleMatch -and $article.article -match $articleMatch) { $matched = $true }
            $searchText = ($article.title + " " + ($article.keywords -join " ") + " " + 
                          ($article.elements -join " ") + " " + $article.legal_effect)
            foreach ($t in $tokens) {
                if ($t.Length -ge 2 -and $searchText -match $t) { $matched = $true }
            }
            
            if ($matched) {
                $results += [PSCustomObject]@{
                    Layer = "law-semantic-tree"
                    Law = $lawName
                    Article = $article.article
                    Title = $article.title
                    Elements = ($article.elements -join "; ")
                    LegalEffect = $article.legal_effect
                    Score = if ($articleMatch -and $article.article -match $articleMatch) { 100 } else { 50 }
                }
            }
        }
    }
} catch { Write-Step "  law-semantic-tree.json: $_" }

# 1b. 搜索 judicial-interpretations.json
try {
    $jiTree = Get-Content $JUDICIAL_TREE -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($jiProp in $jiTree.judicial_interpretations.PSObject.Properties) {
        foreach ($rule in $jiProp.Value.rules) {
            $searchText = "$($rule.article) $($rule.target_law) $($rule.key_rule) $($rule.keywords -join ' ')"
            foreach ($t in $tokens) {
                if ($t.Length -ge 2 -and $searchText -match $t) {
                    $results += [PSCustomObject]@{
                        Layer = "judicial-interpretation"
                        Law = $jiProp.Name
                        Article = $rule.article
                        Title = $rule.target_law
                        Elements = $rule.key_rule
                        LegalEffect = ($rule.practical_points -join "; ")
                        Score = 40
                    }
                }
            }
        }
    }
    foreach ($case in $jiTree.guiding_cases) {
        $searchText = "$($case.number) $($case.area) $($case.key_rule)"
        foreach ($t in $tokens) {
            if ($t.Length -ge 2 -and $searchText -match $t) {
                $results += [PSCustomObject]@{
                    Layer = "guiding-case"
                    Law = $case.area
                    Article = $case.number
                    Title = $case.court
                    Elements = $case.key_rule
                    LegalEffect = $case.practical_points
                    Score = 35
                }
            }
        }
    }
} catch { Write-Step "  judicial-interpretations.json: $_" }

# 1c. 搜索 regulatory-compliance-tree.json
try {
    $regTree = Get-Content $REGULATORY_TREE -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($regProp in $regTree.regulations.PSObject.Properties) {
        foreach ($rule in $regProp.Value.rules) {
            $searchText = "$($rule.name) $($rule.trigger -join ' ') $($rule.obligation) $($rule.keywords -join ' ')"
            foreach ($t in $tokens) {
                if ($t.Length -ge 2 -and $searchText -match $t) {
                    $results += [PSCustomObject]@{
                        Layer = "regulatory-compliance"
                        Law = $regProp.Name
                        Article = $rule.name
                        Title = $rule.regulation
                        Elements = ($rule.trigger -join " | ")
                        LegalEffect = "$($rule.obligation) | 罚则: $($rule.penalty)"
                        Score = 40
                    }
                }
            }
        }
    }
} catch { Write-Step "  regulatory-compliance-tree.json: $_" }

# ============================================================
# 输出
# ============================================================
$results = $results | Sort-Object Score -Descending

if ($results.Count -gt 0) {
    Write-Host "本地命中 $($results.Count) 条结果" -ForegroundColor Green
    Write-Host ""
    $results | Select-Object -First 5 | Format-List @{N='来源';E={$_.Layer}}, @{N='法律/领域';E={$_.Law}},
        @{N='法条/规则';E={$_.Article}}, @{N='标题';E={$_.Title}},
        @{N='构成要件/触发条件';E={$_.Elements}}, @{N='法律效果/合规义务';E={$_.LegalEffect}}
    exit 0
}

# ============================================================
# Layer 2: MCP
# ============================================================
if (-not $LocalOnly) {
    Write-Step "[Layer 2] 本地未命中，尝试MCP..."
    Write-Host ""
    Write-Host "MCP检索需在Codex Desktop中执行:" -ForegroundColor Yellow
    Write-Host "  pkulaw: codex mcp call pkulaw search --query '$Query'"
    Write-Host ""
    
    # ============================================================
    # Layer 3: Browser
    # ============================================================
    Write-Step "[Layer 3] 浏览器查询队列..."
    try {
        $cfg = Get-Content $CONFIG_FILE -Raw -Encoding UTF8 | ConvertFrom-Json
        $urls = $cfg.browser.urls | Sort-Object Priority
        Write-Host ""
        Write-Host "=== 浏览器查询URL ===" -ForegroundColor Cyan
        foreach ($u in $urls) {
            $encoded = [uri]::EscapeDataString($Query)
            $full = $u.template -replace '\{query\}', $encoded
            Write-Host "  [$($u.priority)] $($u.name): $full"
        }
    } catch {
        Write-Host "配置读取失败: $_" -ForegroundColor Red
    }
} else {
    Write-Host "本地未命中 (LocalOnly模式)" -ForegroundColor Red
    exit 1
}

