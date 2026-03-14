---
name: course-generator
description: 课程讲义生成技能。自动生成超详细的课程讲义，包含深度源码分析、完整示例、FAQ等。支持子agent并行生成，自动创建GitHub仓库并上传。适用于大学课程、技术培训、教程制作等场景。
---

# 课程讲义生成技能

## 何时使用

当用户需要：
- 生成课程讲义（大学课程、技术培训、教程）
- 创建详细的技术文档
- 编写深度教程（源码分析+实战）
- 制作结构化的学习材料
- 整合知识到GitHub仓库

## 核心工作流

### 阶段1：需求收集（1分钟）

**收集信息**：
- 课程名称和版本（如：Spring Boot v2.3.12.RELEASE）
- 课程层次（本科高级/研究生/职业培训）
- 学时分配（理论+实验）
- 授课对象
- 重点方向（理论/实战/项目）

**输出**：课程需求单

### 阶段2：初版生成（5-10分钟）

**生成内容**：
- 课程大纲
- 模块划分
- 知识点列表
- 基础内容框架

**工具**：
- 直接生成（小课程）
- 或使用子agent并行生成（大课程）

### 阶段3：详细版生成（10-30分钟）

**触发条件**：
- 用户要求"更详细"
- 需要深度内容
- 大型课程（>5万字）

**执行方式**：
```python
# 使用子agent并行生成
sessions_spawn(
    runtime="subagent",
    task="生成超详细版课程讲义...",
    mode="session",
    thread=True
)
```

**生成内容**：
- 每个知识点 5000-15000 字
- 深度源码分析（逐行注释）
- 完整代码示例（200+）
- FAQ（每个知识点4-5个）
- 最佳实践建议

### 阶段4：内容整理（5分钟）

**整理任务**：
1. 合并子agent输出
2. 统一格式和风格
3. 检查完整性
4. 添加目录和索引
5. 生成统计报告

**输出**：
- 完整讲义文件（Markdown）
- 统计报告（字数、模块、示例等）

### 阶段5：发布到GitHub（5-10分钟）

**发布目标**：

1. **创建GitHub仓库**（自动）
   - 使用 `gh repo create` 创建公开仓库
   - 添加仓库描述和topics
   - 生成 README.md（含完整大纲）

2. **上传课程文件**（完整内容）
   - 上传完整讲义Markdown文件
   - 如文件>100KB，提供合并版本
   - 提供 LICENSE（MIT许可）

3. **生成交付报告**
   - GitHub仓库链接
   - 文件统计信息
   - 访问方式说明

**工具**：
- `gh` - GitHub CLI
- `publish_course.py` - 自动发布脚本

**优势**：
- ✅ 无文件大小限制
- ✅ 完美支持Markdown格式
- ✅ 易于版本控制和更新
- ✅ 便于分享和协作

### 阶段6：交付确认（1分钟）

**交付物**：
- 📦 GitHub 仓库链接（公开可访问）
- 📄 完整讲义文件（本地+GitHub）
- 📊 生成报告（统计信息）
- 🔗 快速访问说明

## 快速开始

### 使用方式1：AI 自动化（推荐）

直接告诉 AI：

```
请生成 Spring Boot v2.3.12 课程讲义
- 课程层次：本科高级
- 学时：48学时（理论36 + 实验12）
- 重点：深度源码分析 + 实战示例
```

AI 会自动执行完整流程。

### 使用方式2：分步骤执行

```bash
# 1. 生成初版
python3 scripts/generate_course.py --name "Spring Boot" --version "v2.3.12"

# 2. 生成详细版（使用子agent）
python3 scripts/generate_detailed.py --course-file /tmp/course-basic.md

# 3. 整理内容
python3 scripts/organize_content.py /tmp/course-raw/

# 4. 发布到飞书+GitHub
python3 scripts/publish_course.py /tmp/course-final.md "spring-boot-course"
```

## 课程模板

### 课程结构模板

```
# 课程标题

**课程名称**: [课程名称]  
**课程层次**: [层次]  
**学分**: [学分]  
**总学时**: [总学时]  
**授课对象**: [对象]  
**授课教师**: [教师]  
**教材版本**: [版本]  
**课程学期**: [学期]

---

# 第一部分：详细讲义

---

# 模块 N️⃣: [模块名称]

## 理论学时: X学时 | 实验学时: X学时

---

## 知识点 N: [知识点名称]（X学时）

### [子知识点1]
- 核心定义
- 深度解析
- 源码分析
- 实战示例

### FAQ
- Q1: ...
- A1: ...

### 思考题
- Q1: ...
```

### 内容深度标准

**每个知识点应包含**：

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
   - 理解性问题
   - 实践性问题

**总字数**：每个知识点 5000-15000 字

## 输出规格

### 文档规格

| 项目 | 规格 |
|------|------|
| 总字数 | 30万字（超详细版） |
| 总行数 | 10,000行 |
| 文件大小 | 256KB |
| 模块数 | 8大模块 |
| 知识点数 | 18个 |
| 代码示例 | 200+ |
| FAQ | 60+ |

### 内容特色

- ✅ 深度源码分析（30+核心类）
- ✅ 详细配置说明（65+配置项）
- ✅ 完整代码示例（200+可运行）
- ✅ 架构设计图（流程图、时序图）
- ✅ 常见问题解答（60+ FAQ）
- ✅ 最佳实践建议（50+建议）
- ✅ 性能调优指南
- ✅ 错误排查方法

## 子Agent并行生成

### 何时使用子Agent

**触发条件**：
- 课程超过5万字
- 需要深度内容
- 包含多个独立模块
- 需要快速生成

### 并行策略

```python
# 按模块分割
modules = [
    "模块1-2：基础篇",
    "模块3-5：实战篇", 
    "模块6-8：进阶篇"
]

# 并行生成
for module in modules:
    sessions_spawn(
        runtime="subagent",
        task=f"生成{module}的超详细内容...",
        mode="session",
        thread=True  # 持久化会话
    )
```

### 监控和收集

```python
# 查看子agent状态
subagents(action="list")

# 获取子agent输出
sessions_history(sessionKey="agent:main:subagent:xxx")
```

## 发布方案

### GitHub 仓库创建

**自动创建流程**：

```bash
# 1. 创建仓库
gh repo create simpletfh/course-name --public --description "课程讲义"

# 2. 初始化本地Git
cd /tmp/course-workspace
git init
git add .
git commit -m "docs: 课程讲义初始版本"

# 3. 推送到GitHub
git remote add origin https://github.com/simpletfh/course-name.git
git push -u origin main

# 4. 添加README
gh repo edit --description "课程描述" --add-topic "spring,tutorial"
```

### 文件组织策略

| 课程大小 | 推荐策略 | 说明 |
|---------|---------|------|
| < 100KB | 单文件 | 直接上传完整文件 |
| 100KB-500KB | 合并文件 | 提供1个完整文件 |
| > 500KB | 分片+合并 | 提供分片（模块）+ 完整合并文件 |

### README 模板

```markdown
# 📘 [课程名称]

**课程层次**: [层次]  
**总学时**: [学时]  
**版本**: [版本]

---

## 📚 课程内容

### 在线阅读
- **GitHub**: https://github.com/user/repo/blob/main/course-complete.md

### 本地克隆
```bash
git clone https://github.com/user/repo.git
```

## 📖 课程大纲

### 模块1：[名称]
- 知识点1
- 知识点2

[... 更多模块]
```

## 故障排查

### 子Agent失败

**问题**：子agent任务失败或超时

**解决**：
```python
# 检查状态
subagents(action="list", recentMinutes=10)

# 重启失败的agent
subagents(action="kill", target="failed-agent-id")
# 重新spawn
```

### 内容合并错误

**问题**：子agent输出格式不统一

**解决**：
```python
# 使用organize脚本统一格式
python3 scripts/organize_content.py --fix-format
```

### 发布失败

**问题**：飞书或GitHub上传失败

**解决**：
1. 检查文件大小（< 100KB for 飞书）
2. 使用分批上传
3. 检查GitHub token配置

## 最佳实践

### 内容质量

1. **源码分析**
   - 逐行注释关键代码
   - 解释设计意图
   - 说明执行流程

2. **代码示例**
   - 完整可运行
   - 详细注释
   - 实际场景

3. **FAQ编写**
   - 常见问题
   - 详细解答
   - 提供示例

### 时间控制

| 阶段 | 预计时间 | 说明 |
|------|---------|------|
| 需求收集 | 1分钟 | 明确要求 |
| 初版生成 | 5-10分钟 | 框架内容 |
| 详细生成 | 10-30分钟 | 深度内容（子agent并行） |
| 内容整理 | 5分钟 | 合并优化 |
| 多格式发布 | 5-10分钟 | 飞书+GitHub |
| **总计** | **30-60分钟** | 取决于课程大小 |

## 参考资源

- `references/course-structure.md` - 课程结构模板
- `references/content-standards.md` - 内容质量标准
- `scripts/generate_course.py` - 课程生成脚本
- `scripts/publish_course.py` - 发布脚本

## 成功案例

**Spring Security 5.3.9.RELEASE 课程讲义**
- ✅ 27万字，8大模块，23知识点
- ✅ 200+代码示例，110+FAQ
- ✅ GitHub：https://github.com/simpletfh/spring-security-5.3.9-course
- ✅ 完整文件：792KB，26561行
- ✅ 生成时间：45分钟

**关键数据**：
- 子agent并行生成：4个agent，14分钟
- 输出文件：792KB完整版 + 4个分片
- GitHub仓库：公开，无大小限制
- 格式验证：通过（0问题）

**Spring Boot v2.3.12 课程讲义**
- ✅ 30万字，8大模块
- ✅ 200+代码示例，60+FAQ
- ✅ GitHub：https://github.com/simpletfh/spring-boot-course
- ✅ 生成时间：30分钟

**关键数据**：
- 子agent工作：8分钟并行生成
- 输出文件：256KB，9848行
- GitHub仓库：公开，可访问
