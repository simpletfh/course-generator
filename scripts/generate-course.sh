#!/bin/bash
# 课程讲义生成主控脚本
# 用途：自动化生成课程讲义的完整流程
# 使用：bash generate-course.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COURSE_NAME="${COURSE_NAME:-课程}"
COURSE_VERSION="${COURSE_VERSION:-v1.0}"
OUTPUT_DIR="${OUTPUT_DIR:-/tmp/course-generation}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

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

# 显示帮助
show_help() {
    cat << EOF
课程讲义生成工具 - 完整流程自动化

用法: bash generate-course.sh [选项]

选项:
    -n, --name NAME          课程名称（如：Spring Boot）
    -v, --version VERSION    课程版本（如：v2.3.12.RELEASE）
    -l, --level LEVEL        课程层次（本科/研究生/职业培训）
    -h, --hours HOURS        总学时（如：48）
    -t, --theory HOURS       理论学时（如：36）
    -e, --experiment HOURS   实验学时（如：12）
    -d, --detailed           生成超详细版（使用子agent并行）
    -o, --output DIR         输出目录（默认：/tmp/course-generation）
    --feishu                 上传到飞书
    --github                 上传到GitHub
    --help                   显示此帮助信息

示例:
    # 基础版讲义
    bash generate-course.sh -n "Spring Boot" -v "v2.3.12" -l "本科高级"

    # 超详细版讲义（使用子agent）
    bash generate-course.sh -n "Spring Boot" -v "v2.3.12" -d --feishu

    # 完整流程（生成+发布）
    bash generate-course.sh -n "Spring Boot" -v "v2.3.12" -d --feishu --github

环境变量:
    COURSE_NAME              课程名称
    COURSE_VERSION           课程版本
    FEISHU_DOC_TOKEN         飞书文档Token（用于更新已有文档）
    GITHUB_TOKEN             GitHub Token（用于上传）

EOF
}

# 解析命令行参数
COURSE_NAME=""
COURSE_VERSION=""
COURSE_LEVEL=""
TOTAL_HOURS=""
THEORY_HOURS=""
EXPERIMENT_HOURS=""
DETAILED_MODE=false
UPLOAD_FEISHU=false
UPLOAD_GITHUB=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            COURSE_NAME="$2"
            shift 2
            ;;
        -v|--version)
            COURSE_VERSION="$2"
            shift 2
            ;;
        -l|--level)
            COURSE_LEVEL="$2"
            shift 2
            ;;
        -h|--hours)
            TOTAL_HOURS="$2"
            shift 2
            ;;
        -t|--theory)
            THEORY_HOURS="$2"
            shift 2
            ;;
        -e|--experiment)
            EXPERIMENT_HOURS="$2"
            shift 2
            ;;
        -d|--detailed)
            DETAILED_MODE=true
            shift
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --feishu)
            UPLOAD_FEISHU=true
            shift
            ;;
        --github)
            UPLOAD_GITHUB=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 阶段1：验证输入
log_info "=== 阶段1：验证输入 ==="

if [ -z "$COURSE_NAME" ]; then
    log_error "请提供课程名称（使用 -n 或 --name）"
    exit 1
fi

if [ -z "$COURSE_VERSION" ]; then
    COURSE_VERSION="v1.0"
    log_warning "未指定版本，使用默认：$COURSE_VERSION"
fi

# 创建输出目录
COURSE_DIR="$OUTPUT_DIR/${COURSE_NAME}-${COURSE_VERSION}-$TIMESTAMP"
mkdir -p "$COURSE_DIR"

log_success "课程：$COURSE_NAME $COURSE_VERSION"
log_success "输出目录：$COURSE_DIR"

# 保存元数据
cat > "$COURSE_DIR/metadata.json" << EOF
{
  "course_name": "$COURSE_NAME",
  "course_version": "$COURSE_VERSION",
  "course_level": "$COURSE_LEVEL",
  "total_hours": $TOTAL_HOURS,
  "theory_hours": $THEORY_HOURS,
  "experiment_hours": $EXPERIMENT_HOURS,
  "detailed_mode": $DETAILED_MODE,
  "timestamp": "$TIMESTAMP"
}
EOF

# 阶段2：生成大纲
log_info "=== 阶段2：生成课程大纲 ==="

if [ -f "$SCRIPT_DIR/templates/course-outline-template.md" ]; then
    cp "$SCRIPT_DIR/templates/course-outline-template.md" "$COURSE_DIR/outline.md"
    log_info "使用模板大纲"
else
    # 创建基础大纲
    cat > "$COURSE_DIR/outline.md" << EOF
# ${COURSE_NAME} ${COURSE_VERSION} 课程大纲

## 课程信息

- **课程名称**: ${COURSE_NAME}
- **课程版本**: ${COURSE_VERSION}
- **课程层次**: ${COURSE_LEVEL:-本科高级}
- **总学时**: ${TOTAL_HOURS:-48}学时
- **理论学时**: ${THEORY_HOURS:-36}学时
- **实验学时**: ${EXPERIMENT_HOURS:-12}学时

## 模块规划

（待补充）
EOF
    log_info "创建基础大纲"
fi

# 阶段3：生成内容
log_info "=== 阶段3：生成课程内容 ==="

if [ "$DETAILED_MODE" = true ]; then
    log_info "使用子agent并行生成详细内容..."

    if [ -f "$SCRIPT_DIR/spawn-subagents.sh" ]; then
        bash "$SCRIPT_DIR/spawn-subagents.sh" \
            --course-name "$COURSE_NAME" \
            --course-version "$COURSE_VERSION" \
            --output-dir "$COURSE_DIR"
    else
        log_warning "未找到 spawn-subagents.sh，跳过子agent生成"
    fi
else
    log_info "生成基础版内容..."
    cat > "$COURSE_DIR/course-basic.md" << EOF
# ${COURSE_NAME} ${COURSE_VERSION} 课程讲义

## 第一部分：课程概述

（待生成详细内容）
EOF
fi

# 阶段4：整理内容
log_info "=== 阶段4：整理内容 ==="

if [ -f "$SCRIPT_DIR/organize-content.sh" ]; then
    bash "$SCRIPT_DIR/organize-content.sh" \
        --course-dir "$COURSE_DIR" \
        --detailed "$DETAILED_MODE"
else
    log_warning "未找到 organize-content.sh，跳过内容整理"
fi

# 阶段5：发布
if [ "$UPLOAD_FEISHU" = true ] || [ "$UPLOAD_GITHUB" = true ]; then
    log_info "=== 阶段5：发布内容 ==="

    if [ "$UPLOAD_FEISHU" = true ]; then
        log_info "上传到飞书..."
        if [ -f "$SCRIPT_DIR/publish-to-feishu.sh" ]; then
            bash "$SCRIPT_DIR/publish-to-feishu.sh" \
                --course-dir "$COURSE_DIR" \
                --title "${COURSE_NAME} ${COURSE_VERSION} 课程讲义"
        else
            log_warning "未找到 publish-to-feishu.sh"
        fi
    fi

    if [ "$UPLOAD_GITHUB" = true ]; then
        log_info "上传到GitHub..."
        if [ -f "$SCRIPT_DIR/publish-to-github.sh" ]; then
            bash "$SCRIPT_DIR/publish-to-github.sh" \
                --course-dir "$COURSE_DIR" \
                --repo-name "${COURSE_NAME}-course"
        else
            log_warning "未找到 publish-to-github.sh"
        fi
    fi
fi

# 完成
log_success "=== 课程讲义生成完成 ==="
log_info "输出目录: $COURSE_DIR"
log_info "元数据: $COURSE_DIR/metadata.json"
log_info "大纲: $COURSE_DIR/outline.md"

if [ -f "$COURSE_DIR/course-final.md" ]; then
    log_info "最终讲义: $COURSE_DIR/course-final.md"
fi

exit 0
