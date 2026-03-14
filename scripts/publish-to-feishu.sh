#!/bin/bash
# 飞书发布脚本
# 用途：将课程讲义上传到飞书文档
# 使用：bash publish-to-feishu.sh --course-dir /tmp/course-xxx --title "课程标题"

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
TITLE=""
DOC_TOKEN=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --course-dir)
            COURSE_DIR="$2"
            shift 2
            ;;
        --title)
            TITLE="$2"
            shift 2
            ;;
        --doc-token)
            DOC_TOKEN="$2"
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

log_info "=== 发布到飞书 ==="
log_info "课程目录: $COURSE_DIR"

# 查找要发布的文件
CONTENT_FILE=""
if [ -f "$COURSE_DIR/course-final.md" ]; then
    CONTENT_FILE="$COURSE_DIR/course-final.md"
elif [ -f "$COURSE_DIR/course-all.md" ]; then
    CONTENT_FILE="$COURSE_DIR/course-all.md"
elif [ -f "$COURSE_DIR/course-basic.md" ]; then
    CONTENT_FILE="$COURSE_DIR/course-basic.md"
else
    log_error "未找到可发布的内容文件"
    exit 1
fi

log_info "内容文件: $CONTENT_FILE"

# 检查文件大小
FILE_SIZE=$(stat -f%z "$CONTENT_FILE" 2>/dev/null || stat -c%s "$CONTENT_FILE" 2>/dev/null)
if [ "$FILE_SIZE" -gt 102400 ]; then
    log_warning "文件大小超过100KB飞书限制（$(du -h "$CONTENT_FILE" | cut -f1)）"
    log_info "将创建索引文档，完整内容保存到文件"
    CREATE_INDEX_ONLY=true
else
    CREATE_INDEX_ONLY=false
fi

# 读取内容
CONTENT=$(cat "$CONTENT_FILE")

if [ -z "$TITLE" ]; then
    # 从内容中提取标题
    TITLE=$(echo "$CONTENT" | grep -m 1 '^# ' | sed 's/^# //')
    if [ -z "$TITLE" ]; then
        TITLE="课程讲义"
    fi
fi

log_info "文档标题: $TITLE"

# 如果提供了 doc_token，直接更新
if [ -n "$DOC_TOKEN" ]; then
    log_info "更新已有飞书文档: $DOC_TOKEN"

    # 注意：这里需要通过 OpenClaw 的 feishu_doc 工具来执行
    # AI 会调用: feishu_doc(action="write", doc_token="$DOC_TOKEN", content="$CONTENT")

    cat > "$COURSE_DIR/feishu-update-prompt.txt" << EOF
请使用 feishu_doc 工具更新飞书文档：

- 文档 Token: $DOC_TOKEN
- 标题: $TITLE
- 内容文件: $CONTENT_FILE

命令示例:
feishu_doc \
  action="write" \
  doc_token="$DOC_TOKEN" \
  content="\$(cat "$CONTENT_FILE")"
EOF

    log_success "更新提示已保存到: $COURSE_DIR/feishu-update-prompt.txt"
else
    # 创建新文档
    log_info "创建新飞书文档"

    # 创建索引文档内容
    if [ "$CREATE_INDEX_ONLY" = true ]; then
        INDEX_CONTENT=$(cat << INDEX
# $TITLE

## 📚 完整内容

由于内容超过飞书文档大小限制，完整内容请查看：

\`\`\`bash
cat $CONTENT_FILE
\`\`\`

## 📊 内容统计

$(echo "$CONTENT" | tail -20)

## 📁 文件信息

- **文件路径**: $CONTENT_FILE
- **文件大小**: $(du -h "$CONTENT_FILE" | cut -f1)
- **总行数**: $(wc -l < "$CONTENT_FILE") 行
- **总字数**: $(wc -w < "$CONTENT_FILE") 字

---

*生成时间: $(date '+%Y-%m-%d %H:%M:%S')*
INDEX
)

        cat > "$COURSE_DIR/feishu-index-content.md" <<< "$INDEX_CONTENT"
        log_info "索引内容已保存到: $COURSE_DIR/feishu-index-content.md"

        cat > "$COURSE_DIR/feishu-create-prompt.txt" << EOF
请使用 feishu_doc 工具创建飞书索引文档：

- 标题: $TITLE
- 内容文件: $COURSE_DIR/feishu-index-content.md

命令示例:
feishu_doc \
  action="create" \
  title="$TITLE" \
  content="\$(cat "$COURSE_DIR/feishu-index-content.md")"
EOF
    else
        cat > "$COURSE_DIR/feishu-create-prompt.txt" << EOF
请使用 feishu_doc 工具创建飞书文档：

- 标题: $TITLE
- 内容文件: $CONTENT_FILE

命令示例:
feishu_doc \
  action="create" \
  title="$TITLE" \
  content="\$(cat "$CONTENT_FILE")"
EOF
    fi

    log_success "创建提示已保存到: $COURSE_DIR/feishu-create-prompt.txt"
fi

# 创建发布说明
cat > "$COURSE_DIR/feishu-publish-instructions.md" << 'INSTRUCTIONS'
# 飞书发布说明

## 方式1：AI 自动执行（推荐）

直接告诉 AI：
```
请将课程讲义上传到飞书
```

AI 会自动：
1. 读取 $COURSE_DIR/feishu-create-prompt.txt
2. 调用 feishu_doc 工具
3. 创建文档并返回链接

## 方式2：手动执行

如果需要手动执行，使用以下命令：

### 创建新文档
```bash
# 通过 OpenClaw CLI
openclaw feishu-doc create \
  --title "$TITLE" \
  --file "$CONTENT_FILE"
```

### 更新已有文档
```bash
# 通过 OpenClaw CLI
openclaw feishu-doc write \
  --doc-token "$DOC_TOKEN" \
  --file "$CONTENT_FILE"
```

## 注意事项

1. **文件大小限制**: 飞书文档最大100KB
2. **超过限制**: 自动创建索引文档，完整内容保留在文件中
3. **权限**: 创建的文档默认你有编辑权限
4. **分享**: 可以在飞书中分享文档链接给他人

INSTRUCTIONS

log_success "发布说明已保存到: $COURSE_DIR/feishu-publish-instructions.md"

# 输出摘要
log_success "飞书发布准备完成"
log_info "下一步："
log_info "  1. 查看发布说明: cat $COURSE_DIR/feishu-publish-instructions.md"
log_info "  2. 让 AI 执行发布"
log_info "  3. 或者手动执行提示中的命令"

exit 0
