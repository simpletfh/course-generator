#!/usr/bin/env python3
"""
课程讲义生成脚本
"""

import sys
import os
import argparse
from datetime import datetime

def generate_course_outline(name, version, level, hours, theory_hours, lab_hours):
    """生成课程大纲"""
    
    outline = f"""# {name} 课程讲义

**课程名称**: {name}
**教材版本**: {version}
**课程层次**: {level}
**学分**: {hours // 16} 学分
**总学时**: {hours} 学时（理论 {theory_hours} + 实验 {lab_hours}）
**授课对象**: 计算机科学与技术专业 高年级本科生
**授课教师**: 汤
**课程学期**: 2026年春季学期

---

## 课程简介

本课程深入讲解 {name} {version} 的核心原理和实战应用，通过理论学习和实验操作，使学生掌握 {name} 的核心技术和最佳实践。

---

## 课程大纲

### 模块1️⃣: 快速入门与基础概念
**理论学时**: {theory_hours // 4}学时 | **实验学时**: {lab_hours // 4}学时

- 知识点1: {name} 是什么？
- 知识点2: 第一个 {name} 应用
- 知识点3: 理解核心注解
- 知识点4: 配置文件基础

### 模块2️⃣: 核心原理深度剖析
**理论学时**: {theory_hours // 4}学时 | **实验学时**: {lab_hours // 4}学时

- 知识点5: 启动流程
- 知识点6: 配置加载机制
- 知识点7: 条件注解体系

### 模块3️⃣: 实战开发核心
**理论学时**: {theory_hours // 4}学时 | **实验学时**: {lab_hours // 4}学时

- 知识点8: RESTful API 开发
- 知识点9: 嵌入式容器
- 知识点10: 请求处理

### 模块4️⃣: 数据访问与持久化
**理论学时**: {theory_hours // 4}学时 | **实验学时**: {lab_hours // 4}学时

- 知识点11: 数据访问框架
- 知识点12: 事务管理
- 知识点13: 缓存机制

### 模块5️⃣: 安全控制
**理论学时**: {theory_hours // 5}学时 | **实验学时**: {lab_hours // 5}学时

- 知识点14: 安全基础
- 知识点15: JWT 令牌认证
- 知识点16: OAuth2 认证

### 模块6️⃣: 测试体系
**理论学时**: {theory_hours // 6}学时 | **实验学时**: {lab_hours // 6}学时

- 知识点17: 测试基础

### 模块7️⃣: 监控与运维
**理论学时**: {theory_hours // 6}学时 | **实验学时**: {lab_hours // 6}学时

- 知识点18: Actuator 监控
- 日志管理
- 性能优化

### 模块8️⃣: 综合实战项目
**理论学时**: {theory_hours // 8}学时 | **实验学时**: {lab_hours // 8}学时

- 知识点19: 企业级项目实战

---

## 教学方法

- 理论授课：深入讲解核心原理
- 实验操作：动手实践巩固知识
- 项目实战：完整项目提升能力
- 案例分析：实际问题加深理解

---

## 考核方式

- 平时成绩：20%（作业+考勤）
- 期中考试：30%
- 期末考试：30%
- 实验项目：20%

---

## 参考资料

- 官方文档
- 推荐书籍
- 开源项目

---

**文档生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**更新频率**: 按需更新
**维护者**: AI Assistant
"""
    
    return outline

def main():
    parser = argparse.ArgumentParser(description='课程讲义生成工具')
    parser.add_argument('--name', required=True, help='课程名称')
    parser.add_argument('--version', default='v1.0.0', help='教材版本')
    parser.add_argument('--level', default='本科高级', help='课程层次')
    parser.add_argument('--hours', type=int, default=48, help='总学时')
    parser.add_argument('--theory-hours', type=int, help='理论学时')
    parser.add_argument('--lab-hours', type=int, help='实验学时')
    parser.add_argument('--output', default='/tmp/course-outline.md', help='输出文件')
    
    args = parser.parse_args()
    
    # 默认学时分配
    if args.theory_hours is None:
        args.theory_hours = args.hours * 3 // 4
    if args.lab_hours is None:
        args.lab_hours = args.hours - args.theory_hours
    
    # 生成大纲
    outline = generate_course_outline(
        args.name,
        args.version,
        args.level,
        args.hours,
        args.theory_hours,
        args.lab_hours
    )
    
    # 保存文件
    os.makedirs(os.path.dirname(args.output) if os.path.dirname(args.output) else '.', exist_ok=True)
    with open(args.output, 'w', encoding='utf-8') as f:
        f.write(outline)
    
    print(f"✅ 课程大纲已生成: {args.output}")
    print(f"   课程: {args.name} {args.version}")
    print(f"   学时: {args.hours}（理论 {args.theory_hours} + 实验 {args.lab_hours}）")
    print("\n下一步:")
    print("1. 审查大纲结构")
    print("2. 使用 AI 生成详细内容")
    print("3. 发布到飞书和GitHub")

if __name__ == '__main__':
    main()
