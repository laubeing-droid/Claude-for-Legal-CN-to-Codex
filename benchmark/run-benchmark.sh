#!/usr/bin/env bash
# run-benchmark.sh — 中国法 Benchmark 统一测试运行器 (macOS / Linux)
# 用法: bash run-benchmark.sh [--all] [--positive]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="adversarial"
ALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --positive|-p) MODE="positive" ;;
        --all|-a) ALL=true ;;
        *) echo "用法: $0 [--positive] [--all]"; exit 1 ;;
    esac
    shift
done

if [ "$MODE" = "positive" ]; then
    TEST_FILE="$SCRIPT_DIR/positive-tests.md"
    MODE_LABEL="正面（中国法推理正确性）"
else
    TEST_FILE="$SCRIPT_DIR/adversarial-tests.md"
    MODE_LABEL="对抗（美国法概念拦截）"
fi

[ -f "$TEST_FILE" ] || { echo "[!!] 找不到测试用例: $TEST_FILE"; exit 1; }

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; GRAY='\033[0;90m'; NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  中国法 Benchmark — ${MODE_LABEL}${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# ─── 解析测试用例 ─────────────────────────────────────
if [ "$MODE" = "positive" ]; then
    # 解析正面测试（表格驱动）
    cat "$TEST_FILE" | grep -E '^### [0-9]+\.|^\| \*\*' | while IFS= read -r line; do
        echo "$line"
    done
else
    # 解析对抗测试
    grep -E '^\| [0-9]+ \|' "$TEST_FILE" | while IFS= read -r line; do
        echo "$line"
    done
fi | cat  # force pipe completion

COUNT=$(if [ "$MODE" = "positive" ]; then grep -c '^### [0-9]+\.' "$TEST_FILE" || echo 0; else grep -c '^\| [0-9]\+ \|' "$TEST_FILE" || echo 0; fi)
echo -e "${YELLOW}共加载 $COUNT 个测试用例${NC}"
echo ""

if [ "$ALL" = true ]; then
    echo -e "${CYAN}--- 全量用例清单 ---${NC}"
    if [ "$MODE" = "positive" ]; then
        awk '
        /^### [0-9]+\./ { id=substr($2,1,length($2)-1); title=substr($0,index($0,$3)) }
        /\| \*\*查询\*\*/  { gsub(/^\| \*\*查询\*\* \| /,""); gsub(/ \|$/,""); query=$0 }
        /\| \*\*红线\*\*/   { gsub(/^\| \*\*红线\*\* \| /,""); gsub(/ \|$/,""); print "[" id "] " title "\n  查询: " query "\n  红线: " $0 "\n" }
        ' "$TEST_FILE"
    else
        awk -F'|' '/^\| [0-9]+ \|/ {
            gsub(/^ */,"",$2); gsub(/ *$/,"",$2);
            gsub(/^ */,"",$3); gsub(/ *$/,"",$3);
            gsub(/^ */,"",$4); gsub(/ *$/,"",$4);
            gsub(/^ */,"",$5); gsub(/ *$/,"",$5);
            gsub(/^ */,"",$6); gsub(/ *$/,"",$6);
            printf "[%s] %s\n  预期: %s\n  概念: %s\n  程度: %s\n\n", $2, $3, $4, $5, $6
        }' "$TEST_FILE"
    fi
    echo -e "${CYAN}--- 用例结束 ---${NC}"
    echo ""
    echo "在 Codex Desktop 中逐条输入以上查询进行测试。"
else
    echo -e "${YELLOW}交互模式：按 Enter 查看下一条，在 Codex Desktop 中输入查询测试。${NC}"
    echo ""
    
    idx=0
    passed=0; failed=0
    
    if [ "$MODE" = "positive" ]; then
        while IFS= read -r line; do
            if echo "$line" | grep -q '^### '; then
                idx=$((idx + 1))
                title=$(echo "$line" | sed 's/^### [0-9]\+\. //')
                query=$(grep -A20 "$line" "$TEST_FILE" | grep '查询' | head -1 | sed 's/.*\*\* \| \|$//g')
                law=$(grep -A20 "$line" "$TEST_FILE" | grep '预期法条' | head -1 | sed 's/.*\*\* \| \|$//g')
                redline=$(grep -A20 "$line" "$TEST_FILE" | grep '红线' | head -1 | sed 's/.*\*\* \| \|$//g')
                severity=$(grep -A20 "$line" "$TEST_FILE" | grep '严重程度' | head -1 | sed 's/.*\*\* \| \|$//g')
                
                echo -e "${CYAN}========== 测试 #${idx} ==========${NC}"
                echo -e "标题:   ${YELLOW}${title}${NC}"
                echo "查询:   ${query}"
                echo -e "${GREEN}预期法条:${NC} ${GRAY}${law}${NC}"
                echo -e "${RED}红线:   ${redline}${NC}"
                echo ""
                read -r -p "测试通过？(y=通过 / n=失败 / s=跳过): " result
                case "$result" in y|Y) passed=$((passed+1));; n|N) failed=$((failed+1));; esac
                echo ""
            fi
        done < <(grep '^### [0-9]\+\.' "$TEST_FILE")
    else
        while IFS='|' read -r _ id query expected concept severity _; do
            id=$(echo "$id" | xargs)
            query=$(echo "$query" | xargs)
            expected=$(echo "$expected" | xargs)
            concept=$(echo "$concept" | xargs)
            severity=$(echo "$severity" | xargs)
            [ -z "$id" ] && continue
            
            echo -e "${CYAN}========== 测试 #${id} ==========${NC}"
            echo -e "查询:   ${YELLOW}${query}${NC}"
            echo -e "预期:   ${GREEN}${expected}${NC}"
            echo "概念:   ${concept}"
            echo ""
            read -r -p "测试通过？(y=通过 / n=失败 / s=跳过): " result
            case "$result" in y|Y) passed=$((passed+1));; n|N) failed=$((failed+1));; esac
            echo ""
        done < <(grep '^| [0-9]\+ |' "$TEST_FILE")
    fi
    
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  测试完成${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo "通过: $passed / 失败: $failed"
    if [ "$failed" -gt 0 ]; then echo -e "${RED}存在未通过项，建议修复。${NC}"; exit 1
    else echo -e "${GREEN}全部通过！${NC}"; fi
fi
