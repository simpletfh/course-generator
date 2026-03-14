# 课程讲义生成技能

## 📖 技能简介

这个技能帮助你自动生成超详细的课程讲义，包含深度源码分析、完整示例、FAQ等。支持子agent并行生成，自动创建GitHub仓库并发布。

## 🎯 何时使用

- 生成课程讲义（大学课程、技术培训、教程）
- 创建详细的技术文档
- 编写深度教程（源码分析+实战）
- 制作结构化的学习材料

## 🚀 快速开始

### 方式1：AI 自动化（推荐）

直接告诉 AI：

```
请生成 Spring Security 5.3.9.RELEASE 课程讲义
- 课程层次：本科高级
- 学时：48学时（理论36 + 实验12）
- 重点：深度源码分析 + 实战示例
- 发布到GitHub仓库
```

### 方式2：使用脚本

```bash
# 1. 生成课程讲义
python3 /root/.openclaw/workspace/skills/course-generator/scripts/generate_course.py \
  --name "Spring Security" \
  --version "5.3.9.RELEASE" \
  --level "本科高级" \
  --hours 48

# 2. 发布到GitHub
python3 /root/.openclaw/workspace/skills/course-generator/scripts/publish_to_github.py \
  /tmp/spring-security-course-complete.md \
  spring-security-5.3.9-course \
  --title "Spring Security 5.3.9.RELEASE 课程讲义" \
  --level "本科高级" \
  --hours "48学时" \
  --topics "spring-security,spring-boot,security,tutorial"
```

## 📁 技能结构

```
course-generator/
├── SKILL.md                    # 技能说明
├── README.md                   # 使用手册
├── QUICKSTART.md               # 快速开始
├── scripts/                    # 自动化脚本
│   ├── generate_course.py      # 生成课程讲义
│   ├── organize_content.py     # 整理内容
│   ├── publish_to_github.py    # 发布到GitHub（新）
│   └── publish_course.py       # 发布脚本（向后兼容）
├── templates/                  # 课程模板
│   ├── course-structure.md     # 课程结构模板
│   └── content-template.md     # 内容模板
└── references/                 # 参考文档
    ├── course-structure.md     # 课程结构详解
    └── content-standards.md    # 内容质量标准
```

## 💡 工作流程

### 阶段1：需求收集（1分钟）

收集信息：
- 课程名称和版本
- 课程层次
- 学时分配
- 授课对象
- 重点方向

### 阶段2：初版生成（5-10分钟）

生成内容：
- 课程大纲
- 模块划分
- 知识点列表
- 基础内容框架

### 阶段3：详细版生成（10-30分钟）

使用子agent并行生成：
- 每个知识点 5000-15000 字
- 深度源码分析（逐行注释）
- 完整代码示例（200+）
- FAQ（每个知识点4-5个）

### 阶段4：内容整理（5分钟）

整理任务：
- 合并子agent输出
- 统一格式和风格
- 检查完整性
- 添加目录和索引

### 阶段5：发布到GitHub（5-10分钟）

发布目标：
- **创建GitHub仓库**（自动）
  - 使用 `gh repo create` 创建公开仓库
  - 自动生成 README.md
  - 添加 LICENSE（MIT许可）

- **上传课程文件**（完整内容）
  - 上传完整讲义Markdown文件
  - 支持任意大小文件（无限制）
  - 提供在线阅读和克隆

- **生成交付报告**
  - GitHub仓库链接
  - 文件统计信息
  - 访问方式说明

**优势**：
- ✅ 无文件大小限制
- ✅ 完美支持Markdown格式
- ✅ 易于版本控制和更新
- ✅ 便于分享和协作

## 🎓 成功案例

**Spring Boot v2.3.12 课程讲义**
- ✅ 30万字，8大模块，18个知识点
- ✅ 200+代码示例，60+FAQ
- ✅ 飞书索引：3个文档
- ✅ GitHub：https://github.com/simpletfh/spring-boot-course
- ✅ 生成时间：30分钟

## 📊 输出规格

| 项目 | 规格 |
|------|------|
| 总字数 | 30万字（超详细版） |
| 总行数 | 10,000行 |
| 文件大小 | 256KB |
| 模块数 | 8大模块 |
| 知识点数 | 18个 |
| 代码示例 | 200+ |
| FAQ | 60+ |

## ⚙️ 配置要求

- Python 3.6+
- GitHub CLI（可选，用于GitHub上传）
- OpenClaw 2026.3+

## 🔧 故障排查

### 子Agent失败

```python
# 检查状态
subagents(action="list", recentMinutes=10)

# 重启失败的agent
subagents(action="kill", target="failed-agent-id")
```

### 发布失败

1. 检查文件大小（< 100KB for 飞书）
2. 使用分批上传
3. 检查GitHub token配置

## 📚 更多资源

- [课程结构详解](references/course-structure.md)
- [内容质量标准](references/content-standards.md)
- [SKILL.md](SKILL.md) - AI技能说明

---

**技能创建时间**: 2026-03-14
**维护者**: 打工仔
**适用 OpenClaw 版本**: 2026.3+
