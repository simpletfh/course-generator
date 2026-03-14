#!/bin/bash
# 内容整理脚本
# 用途：合并和整理子agent生成的内容
# 使用：bash organize-content.sh --course-dir /tmp/course-xxx --detailed true

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 解析参数
COURSE_DIR=""
DETAILED_MODE="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --course-dir)
            COURSE_DIR="$2"
            shift 2
            ;;
        --detailed)
            DETAILED_MODE="$2"
            shift 2
            ;;
        *)
            log_error "未知选项: $1"
            exit 1
            ;;
    esac
done

if [ -z "$COURSE_DIR" ]; then
    log_error "请指定课程目录（--course-dir）"
    exit 1
fi

log_info "=== 整理课程内容 ==="
log_info "课程目录: $COURSE_DIR"
log_info "详细模式: $DETAILED_MODE"

# 查找子agent生成的文件
log_info "查找生成的内容文件..."

PART_FILES=()
if [ "$DETAILED_MODE" = "true" ]; then
    # 查找所有 part 文件
    while IFS= read -r -d '' file; do
        PART_FILES+=("$file")
    done < <(find "$COURSE_DIR" -name "course-part*.md" -print0)

    if [ ${#PART_FILES[@]} -eq 0 ]; then
        log_warning "未找到任何 part 文件"
        log_info "将使用基础内容文件"

        if [ -f "$COURSE_DIR/course-basic.md" ]; then
            PART_FILES=("$COURSE_DIR/course-basic.md")
        else
            log_error "未找到任何内容文件"
            exit 1
        fi
    fi
else
    # 基础模式
    if [ -f "$COURSE_DIR/course-basic.md" ]; then
        PART_FILES=("$COURSE_DIR/course-basic.md")
    else
        log_error "未找到基础内容文件"
        exit 1
    fi
fi

log_info "找到 ${#PART_FILES[@]} 个内容文件"
for file in "${PART_FILES[@]}"; do
    log_info "  - $(basename "$file")"
done

# 合并内容
log_info "合并内容..."
FINAL_FILE="$COURSE_DIR/course-final.md"

# 添加文件头
cat > "$FINAL_FILE" << 'HEADER'
# 课程讲义

*生成时间：TIMESTAMP*

---

HEADER

# 替换时间戳
sed -i "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M:%S')/" "$FINAL_FILE"

# 添加元数据
if [ -f "$COURSE_DIR/metadata.json" ]; then
    echo "## 课程元信息" >> "$FINAL_FILE"
    echo "" >> "$FINAL_FILE"
    cat "$COURSE_DIR/metadata.json" | jq -r '
      "- **课程名称**: \(.course_name)",
      "- **课程版本**: \(.course_version)",
      "- **课程层次**: \(.course_level // "未指定")",
      "- **总学时**: \(.total_hours // "未指定")学时",
      "- **理论学时**: \(.theory_hours // "未指定")学时",
      "- **实验学时**: \(.experiment_hours // "未指定")学时"
    ' >> "$FINAL_FILE"
    echo "" >> "$FINAL_FILE"
    echo "---" >> "$FINAL_FILE"
    echo "" >> "$FINAL_FILE"
fi

# 合并所有 part 文件
for part_file in "${PART_FILES[@]}"; do
    log_info "处理: $(basename "$part_file")"

    # 移除可能重复的标题（文件头）
    awk '
    BEGIN { skip = 0 }
    /^# 课程讲义/ { skip = 1; next }
    /^---$/ && skip == 1 { skip = 0; next }
    { if (skip == 0) print }
    ' "$part_file" >> "$FINAL_FILE"

    echo "" >> "$FINAL_FILE"
    echo "---" >> "$FINAL_FILE"
    echo "" >> "$FINAL_FILE"
done

# 添加统计信息
log_info "生成统计报告..."

TOTAL_LINES=$(wc -l < "$FINAL_FILE")
TOTAL_WORDS=$(wc -w < "$FINAL_FILE")
FILE_SIZE=$(du -h "$FINAL_FILE" | cut -f1)
CODE_BLOCKS=$(grep -c '^```' "$FINAL_FILE" || echo "0")
CODE_BLOCKS=$((CODE_BLOCKS / 2))  # 成对的代码块

cat >> "$FINAL_FILE" << 'STATS'

---

## 📊 内容统计

STATS

cat >> "$FINAL_FILE" << STATS
- **总行数**: $TOTAL_LINES 行
- **总字数**: $TOTAL_WORDS 字
- **文件大小**: $FILE_SIZE
- **代码示例**: $CODE_BLOCKS 个
- **生成时间**: $(date '+%Y-%m-%d %H:%M:%S')
STATS

# 格式化
log_info "格式化文档..."

# 规范化标题层级
# 确保只有一个顶级 H1
# 移除多余的空行
# 规范化列表格式

sed -i 's/^#\(#\)/\1/' "$FINAL_FILE"  # 减少 H1 为 H2
sed -i '/^$/N;/^\n$/d' "$FINAL_FILE"  # 移除连续空行

# 完成
log_success "内容整理完成"
log_info "最终文件: $FINAL_FILE"
log_info "统计信息:"
log_info "  - 行数: $TOTAL_LINES"
log_info "  - 字数: $TOTAL_WORDS"
log_info "  - 大小: $FILE_SIZE"
log_info "  - 代码示例: $CODE_BLOCKS"

exit 0
