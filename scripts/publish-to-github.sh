#!/bin/bash
# GitHub发布脚本
# 用途：将课程讲义上传到GitHub仓库
# 使用：bash publish-to-github.sh --course-dir /tmp/course-xxx --repo-name spring-boot-course

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
REPO_NAME=""
REPO_OWNER=""
PRIVATE="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --course-dir)
            COURSE_DIR="$2"
            shift 2
            ;;
        --repo-name)
            REPO_NAME="$2"
            shift 2
            ;;
        --repo-owner)
            REPO_OWNER="$2"
            shift 2
            ;;
        --private)
            PRIVATE="true"
            shift
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

log_info "=== 发布到GitHub ==="
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

# 确定仓库名称
if [ -z "$REPO_NAME" ]; then
    if [ -f "$COURSE_DIR/metadata.json" ]; then
        COURSE_NAME=$(jq -r '.course_name // "course"' "$COURSE_DIR/metadata.json")
        REPO_NAME="${COURSE_NAME,,}-course"  # 转小写
    else
        REPO_NAME="course-content"
    fi
fi

log_info "仓库名称: $REPO_NAME"

# 检查 gh CLI
if ! command -v gh &> /dev/null; then
    log_warning "未安装 GitHub CLI (gh)"
    log_info "请安装: https://cli.github.com/"
    log_info "或使用手动方式上传"
fi

# 创建临时Git目录
TEMP_GIT_DIR="$COURSE_DIR/github-publish"
rm -rf "$TEMP_GIT_DIR"
mkdir -p "$TEMP_GIT_DIR"

# 初始化仓库
log_info "准备Git仓库..."

# 创建README.md
cat > "$TEMP_GIT_DIR/README.md" << 'README'
# 课程讲义

本仓库包含完整的课程讲义内容。

## 📚 内容

- **课程讲义**: [course.md](course.md)
- **更新时间**: TIMESTAMP

## 📖 阅读

直接在线阅读 course.md 文件即可。

## 📥 下载

```bash
git clone REPO_URL
cd REPO_NAME
```

## 📄 许可

本课程内容仅供学习使用。

---

*自动生成 - Course Generator Skill*
README

# 替换占位符
sed -i "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M:%S')/" "$TEMP_GIT_DIR/README.md"
sed -i "s/REPO_NAME/$REPO_NAME/g" "$TEMP_GIT_DIR/README.md"
sed -i "s|REPO_URL|https://github.com/$REPO_OWNER/$REPO_NAME|g" "$TEMP_GIT_DIR/README.md"

# 复制内容
cp "$CONTENT_FILE" "$TEMP_GIT_DIR/course.md"

# 复制元数据（如果有）
if [ -f "$COURSE_DIR/metadata.json" ]; then
    cp "$COURSE_DIR/metadata.json" "$TEMP_GIT_DIR/"
fi

# 复制其他资源（如果有）
if [ -d "$COURSE_DIR/resources" ]; then
    cp -r "$COURSE_DIR/resources" "$TEMP_GIT_DIR/"
fi

# 初始化Git
cd "$TEMP_GIT_DIR"
git init
git add .
git commit -m "Initial commit: 课程讲义

- 课程: $(jq -r '.course_name // "Unknown"' "$COURSE_DIR/metadata.json" 2>/dev/null || echo "Unknown")
- 版本: $(jq -r '.course_version // "v1.0"' "$COURSE_DIR/metadata.json" 2>/dev/null || echo "v1.0")
- 生成时间: $(date '+%Y-%m-%d %H:%M:%S')
"

# 创建发布脚本
cat > "$COURSE_DIR/github-publish-script.sh" << 'PUBLISH_SCRIPT'
#!/bin/bash
# GitHub发布脚本 - 由AI或用户执行

set -e

REPO_NAME="REPO_NAME_PLACEHOLDER"
PRIVATE="PRIVATE_PLACEHOLDER"
TEMP_GIT_DIR="TEMP_DIR_PLACEHOLDER"

cd "$TEMP_GIT_DIR"

# 检查是否已认证
if ! gh auth status &> /dev/null; then
    echo "未登录GitHub，请先认证:"
    echo "  gh auth login"
    exit 1
fi

# 创建仓库
echo "创建GitHub仓库: $REPO_NAME"

if [ "$PRIVATE" = "true" ]; then
    gh repo create "$REPO_NAME" --private --source=. --push
else
    gh repo create "$REPO_NAME" --public --source=. --push
fi

echo "仓库创建成功!"
gh repo view "$REPO_NAME" --web
PUBLISH_SCRIPT

# 替换占位符
sed -i "s|REPO_NAME_PLACEHOLDER|$REPO_NAME|g" "$COURSE_DIR/github-publish-script.sh"
sed -i "s|PRIVATE_PLACEHOLDER|$PRIVATE|g" "$COURSE_DIR/github-publish-script.sh"
sed -i "s|TEMP_DIR_PLACEHOLDER|$TEMP_GIT_DIR|g" "$COURSE_DIR/github-publish-script.sh"

chmod +x "$COURSE_DIR/github-publish-script.sh"

# 创建发布说明
cat > "$COURSE_DIR/github-publish-instructions.md" << 'INSTRUCTIONS'
# GitHub 发布说明

## 方式1：AI 自动执行（推荐）

直接告诉 AI：
```
请将课程讲义上传到GitHub
```

AI 会自动：
1. 读取并执行 github-publish-script.sh
2. 创建GitHub仓库
3. 上传内容
4. 返回仓库链接

## 方式2：手动执行

### 步骤1：认证GitHub（首次）
```bash
gh auth login
```

### 步骤2：执行发布脚本
```bash
bash $COURSE_DIR/github-publish-script.sh
```

### 步骤3：访问仓库
脚本会自动打开浏览器显示新创建的仓库。

## 注意事项

1. **GitHub CLI**: 需要先安装 gh CLI
2. **认证**: 首次使用需要认证
3. **权限**: 确保你有创建仓库的权限
4. **可见性**: 默认公开仓库，使用 --private 创建私有仓库

## 手动方式（无gh CLI）

如果没有安装 gh CLI，可以手动上传：

1. 在GitHub上创建新仓库
2. 添加远程仓库：
   ```bash
   cd $TEMP_GIT_DIR
   git remote add origin https://github.com/USERNAME/REPO_NAME.git
   git branch -M main
   git push -u origin main
   ```

INSTRUCTIONS

log_success "GitHub发布准备完成"
log_info "Git目录: $TEMP_GIT_DIR"
log_info "发布脚本: $COURSE_DIR/github-publish-script.sh"
log_info "发布说明: $COURSE_DIR/github-publish-instructions.md"

log_info "下一步："
log_info "  1. 查看发布说明: cat $COURSE_DIR/github-publish-instructions.md"
log_info "  2. 让 AI 执行发布脚本"
log_info "  3. 或者手动执行: bash $COURSE_DIR/github-publish-script.sh"

exit 0
