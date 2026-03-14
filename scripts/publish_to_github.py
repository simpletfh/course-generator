#!/usr/bin/env python3
"""
课程发布脚本 - 创建GitHub仓库并上传课程文件
"""

import os
import sys
import subprocess
import argparse
import tempfile
import shutil
from pathlib import Path

def run_command(cmd, check=True):
    """运行shell命令"""
    print(f"执行: {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if check and result.returncode != 0:
        print(f"❌ 命令失败: {result.stderr}")
        sys.exit(1)
    
    return result

def get_file_stats(file_path):
    """获取文件统计信息"""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        line_count = len(lines)
        char_count = sum(len(line) for line in lines)
        word_count = len(''.join(lines).split())
    
    size_kb = os.path.getsize(file_path) / 1024
    
    return {
        'lines': line_count,
        'chars': char_count,
        'words': word_count,
        'size_kb': size_kb
    }

def create_readme(course_info, file_stats, github_url):
    """创建README.md"""
    
    readme_content = f"""# 📘 {course_info['title']}

**课程名称**: {course_info.get('name', course_info['title'])}
**教材版本**: {course_info.get('version', 'N/A')}
**课程层次**: {course_info.get('level', 'N/A')}
**总学时**: {course_info.get('hours', 'N/A')}
**授课对象**: {course_info.get('audience', 'N/A')}

---

## 📚 课程讲义

### 📊 讲义规模

- **总字数**: 约 {file_stats['words']:,} 字
- **总行数**: {file_stats['lines']:,} 行
- **文件大小**: {file_stats['size_kb']:.1f} KB

---

## 📖 在线阅读

**GitHub**: {github_url}/blob/main/{os.path.basename(course_info['file'])}

### 本地克隆

```bash
git clone {github_url}.git
```

---

## 🎯 课程大纲

"""

    # 添加课程大纲（如果提供）
    if course_info.get('outline'):
        readme_content += course_info['outline']
    
    # 添加技术栈（如果提供）
    if course_info.get('tech_stack'):
        readme_content += f"""
## 🔧 技术栈

{course_info['tech_stack']}
"""
    
    readme_content += f"""

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 LICENSE 文件

---

_课程讲义生成时间: {course_info.get('date', 'N/A')}_

"""

    return readme_content

def create_license():
    """创建MIT LICENSE"""
    
    return """MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

def publish_to_github(file_path, repo_name, course_info=None):
    """发布到GitHub"""
    
    print("=" * 60)
    print("🚀 课程发布到GitHub")
    print("=" * 60)
    
    # 检查文件
    if not os.path.exists(file_path):
        print(f"❌ 文件不存在: {file_path}")
        return None
    
    # 获取文件统计
    stats = get_file_stats(file_path)
    print(f"\n📊 文件统计:")
    print(f"  - 大小: {stats['size_kb']:.1f} KB")
    print(f"  - 行数: {stats['lines']:,}")
    print(f"  - 字数: {stats['words']:,}")
    
    # 准备课程信息
    if course_info is None:
        course_info = {
            'title': os.path.basename(file_path).replace('.md', '').replace('-', ' ').title(),
            'file': os.path.basename(file_path)
        }
    else:
        course_info['file'] = os.path.basename(file_path)
    
    # 创建临时工作目录
    with tempfile.TemporaryDirectory() as tmpdir:
        print(f"\n📁 创建临时工作目录: {tmpdir}")
        
        # 复制文件
        course_file = os.path.join(tmpdir, os.path.basename(file_path))
        shutil.copy2(file_path, course_file)
        print(f"✅ 复制课程文件")
        
        # 初始化Git仓库
        print(f"\n🔧 初始化Git仓库...")
        run_command(['git', 'init'], cwd=tmpdir)
        run_command(['git', 'config', 'user.name', 'Course Generator'], cwd=tmpdir)
        run_command(['git', 'config', 'user.email', 'course@example.com'], cwd=tmpdir)
        
        # 创建README
        print(f"\n📝 创建README.md...")
        readme_path = os.path.join(tmpdir, 'README.md')
        
        # 先创建仓库获取URL
        full_repo_name = f"simpletfh/{repo_name}"
        repo_url = f"https://github.com/{full_repo_name}"
        
        readme_content = create_readme(course_info, stats, repo_url)
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(readme_content)
        print(f"✅ README.md 已创建")
        
        # 创建LICENSE
        print(f"\n📄 创建LICENSE...")
        license_path = os.path.join(tmpdir, 'LICENSE')
        with open(license_path, 'w', encoding='utf-8') as f:
            f.write(create_license())
        print(f"✅ LICENSE 已创建")
        
        # 提交所有文件
        print(f"\n📦 提交文件...")
        run_command(['git', 'add', '.'], cwd=tmpdir)
        run_command(['git', 'commit', '-m', f'docs: {course_info["title"]} 课程讲义'], cwd=tmpdir)
        
        # 创建GitHub仓库
        print(f"\n🌟 创建GitHub仓库...")
        repo_desc = course_info.get('description', f"{course_info['title']} - 完整课程讲义")
        
        try:
            # 尝试创建仓库（如果已存在会失败，这是预期的）
            result = run_command([
                'gh', 'repo', 'create', full_repo_name,
                '--public',
                '--description', repo_desc,
                '--source=tmpdir',
                '--push'
            ], cwd=tmpdir, check=False)
            
            if result.returncode == 0:
                print(f"✅ 仓库创建成功")
            else:
                # 仓库可能已存在，直接push
                print(f"⚠️  仓库可能已存在，尝试推送...")
                run_command(['git', 'remote', 'add', 'origin', f'https://github.com/{full_repo_name}.git'], cwd=tmpdir)
                run_command(['git', 'branch', '-M', 'main'], cwd=tmpdir)
                run_command(['git', 'push', '-u', 'origin', 'main'], cwd=tmpdir)
        
        except Exception as e:
            print(f"❌ 创建仓库失败: {e}")
            return None
        
        # 添加topics
        if course_info.get('topics'):
            print(f"\n🏷️  添加topics...")
            topics = ' '.join(course_info['topics'])
            run_command(['gh', 'repo', 'edit', full_repo_name, '--add-topic', topics], check=False)
    
    print("\n" + "=" * 60)
    print("✅ 发布完成！")
    print("=" * 60)
    
    print(f"\n📦 GitHub 仓库:")
    print(f"   URL: {repo_url}")
    print(f"   文件: {repo_url}/blob/main/{os.path.basename(file_path)}")
    
    return repo_url

def main():
    parser = argparse.ArgumentParser(description='课程发布工具 - 发布到GitHub')
    parser.add_argument('file', help='课程文件路径')
    parser.add_argument('repo_name', help='GitHub仓库名称（如: spring-security-course）')
    
    # 课程信息（可选）
    parser.add_argument('--title', help='课程标题')
    parser.add_argument('--name', help='课程名称')
    parser.add_argument('--version', help='教材版本')
    parser.add_argument('--level', help='课程层次')
    parser.add_argument('--hours', help='总学时')
    parser.add_argument('--audience', help='授课对象')
    parser.add_argument('--description', help='仓库描述')
    parser.add_argument('--topics', help='仓库topics（逗号分隔）')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.file):
        print(f"❌ 文件不存在: {args.file}")
        sys.exit(1)
    
    # 准备课程信息
    course_info = {}
    if args.title:
        course_info['title'] = args.title
    if args.name:
        course_info['name'] = args.name
    if args.version:
        course_info['version'] = args.version
    if args.level:
        course_info['level'] = args.level
    if args.hours:
        course_info['hours'] = args.hours
    if args.audience:
        course_info['audience'] = args.audience
    if args.description:
        course_info['description'] = args.description
    if args.topics:
        course_info['topics'] = args.topics.split(',')
    
    # 添加日期
    from datetime import datetime
    course_info['date'] = datetime.now().strftime('%Y-%m-%d')
    
    # 发布
    repo_url = publish_to_github(args.file, args.repo_name, course_info if course_info else None)
    
    if repo_url:
        print(f"\n🎉 成功！课程已发布到GitHub")
        print(f"📦 {repo_url}")
    else:
        print(f"\n❌ 发布失败")
        sys.exit(1)

if __name__ == '__main__':
    main()
