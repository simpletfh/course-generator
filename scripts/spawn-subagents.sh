#!/bin/bash
# 子Agent并行生成脚本
# 用途：启动多个子agent并行生成课程内容
# 使用：bash spawn-subagents.sh --course-name "Spring Boot" --course-version "v2.3.12"

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
COURSE_NAME=""
COURSE_VERSION=""
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --course-name)
            COURSE_NAME="$2"
            shift 2
            ;;
        --course-version)
            COURSE_VERSION="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            log_error "未知选项: $1"
            exit 1
            ;;
    esac
done

if [ -z "$COURSE_NAME" ] || [ -z "$OUTPUT_DIR" ]; then
    log_error "缺少必要参数"
    exit 1
fi

log_info "=== 启动子Agent并行生成 ==="
log_info "课程: $COURSE_NAME $COURSE_VERSION"
log_info "输出目录: $OUTPUT_DIR"

# 创建任务描述文件
TASK_PROMPT="$OUTPUT_DIR/task-prompt.md"
cat > "$TASK_PROMPT" << 'EOF'
# 课程讲义生成任务

## 任务目标

生成超详细版课程讲义，每个知识点 5000-15000 字，包含：

1. **核心定义**（1000-2000字）
   - 是什么
   - 为什么需要
   - 解决什么问题

2. **深度解析**（2000-5000字）
   - 工作原理
   - 源码分析（带注释）
   - 执行流程

3. **实战示例**（1000-2000字）
   - 完整代码
   - 代码注释
   - 运行结果

4. **FAQ**（500-1000字）
   - 4-5个常见问题
   - 详细解答

5. **思考题**（3-5个）

## 内容要求

- 深度源码分析（逐行注释关键代码）
- 完整可运行代码示例
- 实际场景应用
- 最佳实践建议
- 常见陷阱和解决方案

## 输出格式

生成单个 Markdown 文件，包含：
- 课程元信息
- 完整目录
- 所有模块和知识点内容
- FAQ 和思考题
- 统计信息（字数、行数、示例数等）
EOF

# 创建模块划分配置
MODULES_CONFIG="$OUTPUT_DIR/modules.json"
cat > "$MODULES_CONFIG" << EOF
{
  "course_name": "$COURSE_NAME",
  "course_version": "$COURSE_VERSION",
  "modules": [
    {
      "id": 1,
      "name": "快速入门与基础概念",
      "topics": ["核心概念", "第一个应用", "注解解析", "配置文件"],
      "output": "course-part1.md"
    },
    {
      "id": 2,
      "name": "核心原理深度剖析",
      "topics": ["启动流程", "配置加载", "条件注解", "自动配置"],
      "output": "course-part2.md"
    },
    {
      "id": 3,
      "name": "Web开发与数据访问",
      "topics": ["RESTful API", "嵌入式容器", "数据持久化", "缓存集成"],
      "output": "course-part3.md"
    }
  ]
}
EOF

# 注意：实际的子agent spawn 需要通过 OpenClaw 的 API 来完成
# 这里只是准备环境和配置

log_info "准备完成，等待 AI 执行子agent spawn..."
log_info "任务描述: $TASK_PROMPT"
log_info "模块配置: $MODULES_CONFIG"

# 创建子agent启动脚本（供AI调用）
cat > "$OUTPUT_DIR/spawn-agents.sh" << 'SPAWN_SCRIPT'
#!/bin/bash
# 此脚本由 AI 调用，用于启动子agent

# 示例：启动3个子agent并行生成
# agent 1: 模块1-2
# agent 2: 模块3-4
# agent 3: 模块5-6

echo "启动子agent任务..."
echo "请使用 sessions_spawn 工具来启动子agent"
SPAWN_SCRIPT

chmod +x "$OUTPUT_DIR/spawn-agents.sh"

log_success "配置完成"
log_info "AI 可以通过以下方式启动子agent："
log_info "  sessions_spawn(runtime='subagent', task=..., mode='session', thread=True)"

exit 0
