# 课程讲义生成技能 - 快速使用指南

## 🚀 快速开始

### 方式1：让 AI 自动执行（推荐）

直接告诉 AI 你需要什么：

```
请生成 Spring Boot v2.3.12 课程讲义
- 课程层次：本科高级
- 学时：48学时（理论36 + 实验12）
- 重点：深度源码分析 + 实战示例
- 生成超详细版（30万字）
- 上传到飞书
```

AI 会自动执行完整流程并返回飞书链接。

### 方式2：使用脚本

```bash
cd /root/.openclaw/workspace/skills/course-generator/scripts

# 基础版
bash generate-course.sh -n "Spring Boot" -v "v2.3.12" -l "本科高级"

# 超详细版（使用子agent并行）
bash generate-course.sh -n "Spring Boot" -v "v2.3.12" -d

# 完整流程（生成+飞书+GitHub）
bash generate-course.sh -n "Spring Boot" -v "v2.3.12" -d --feishu --github
```

## 📋 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `-n, --name` | 课程名称 | `Spring Boot` |
| `-v, --version` | 课程版本 | `v2.3.12.RELEASE` |
| `-l, --level` | 课程层次 | `本科高级` / `研究生` |
| `-h, --hours` | 总学时 | `48` |
| `-t, --theory` | 理论学时 | `36` |
| `-e, --experiment` | 实验学时 | `12` |
| `-d, --detailed` | 生成详细版（使用子agent） | - |
| `--feishu` | 上传到飞书 | - |
| `--github` | 上传到GitHub | - |

## 📊 输出规格

### 基础版（~5万字）
- 生成时间：5-10分钟
- 适用场景：快速讲义、基础教程
- 输出：单一 Markdown 文件

### 详细版（~30万字）
- 生成时间：30-60分钟
- 适用场景：完整课程、深度教程
- 输出：
  - 完整讲义文件（256KB）
  - 飞书索引文档
  - GitHub 仓库（可选）

## 🎯 内容标准

### 每个知识点包含

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

### 统计数据（30万字讲义）

- 总字数：300,000 字
- 总行数：10,000 行
- 文件大小：256 KB
- 模块数：8 大模块
- 知识点：18 个
- 代码示例：200+
- FAQ：60+

## 📁 文件结构

```
course-generator/
├── SKILL.md                    # 技能定义
├── README.md                   # 本文件
├── QUICKSTART.md              # 快速开始（本文件）
├── scripts/
│   ├── generate-course.sh      # 主控脚本
│   ├── spawn-subagents.sh      # 子agent生成
│   ├── organize-content.sh     # 内容整理
│   ├── publish-to-feishu.sh    # 飞书发布
│   └── publish-to-github.sh    # GitHub发布
├── templates/
│   └── course-outline-template.md  # 课程大纲模板
└── references/
    ├── course-structure.md     # 课程结构参考
    └── content-standards.md    # 内容质量标准
```

## 💡 使用场景

### 场景1：大学课程讲义

```
请生成《数据结构》课程讲义
- 课程层次：本科
- 学时：64学时（理论48 + 实验16）
- 重点：算法原理 + 代码实现
- 生成详细版
```

### 场景2：技术培训教程

```
请生成《Docker 实战》教程
- 课程层次：职业培训
- 重点：实战案例 + 最佳实践
- 生成基础版即可
- 上传到飞书
```

### 场景3：深度源码分析

```
请生成《Spring Boot 源码深度解析》
- 课程层次：研究生
- 重点：逐行源码分析 + 架构设计
- 生成超详细版（50万字）
- 上传到飞书和GitHub
```

## 🔧 高级用法

### 自定义课程大纲

1. 修改 `templates/course-outline-template.md`
2. 添加自己的模块和知识点
3. 运行生成脚本

### 调整内容深度

编辑 `references/content-standards.md`，调整：
- 每个知识点的字数要求
- 源码分析的深度
- FAQ 的数量
- 代码示例的复杂度

### 子Agent并行策略

编辑 `scripts/spawn-subagents.sh` 中的模块划分，按你的需求调整：
- 模块数量
- 每个模块包含的知识点
- 并行度（2-4个子agent）

## ⚠️ 注意事项

### 文件大小限制

- **飞书文档**：最大 100KB
  - 超过自动创建索引文档
  - 完整内容保留在文件中
- **GitHub**：无限制

### 生成时间

- 基础版：5-10 分钟
- 详细版：30-60 分钟
  - 子agent并行：8-15 分钟
  - 内容整理：5 分钟
  - 发布：5-10 分钟

### 最佳实践

1. **首次使用**：先生成基础版，确认大纲和结构
2. **二次生成**：使用 `--detailed` 生成详细版
3. **定期保存**：每个阶段都会保存中间文件
4. **版本管理**：输出目录带时间戳，保留多个版本

## 📞 获取帮助

遇到问题？

1. 查看完整文档：`SKILL.md`
2. 运行帮助：`bash scripts/generate-course.sh --help`
3. 让 AI 排查：直接描述问题

## 🎉 成功案例

**Spring Boot v2.3.12 课程讲义**
- ✅ 30万字，8大模块
- ✅ 200+代码示例，60+FAQ
- ✅ 飞书索引：3个文档
- ✅ GitHub：https://github.com/simpletfh/spring-boot-course
- ✅ 生成时间：30分钟

---

**最后更新**: 2026-03-14
**版本**: v1.0
