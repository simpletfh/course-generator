#!/usr/bin/env python3
"""
课程发布脚本 - 发布到GitHub（向后兼容）
"""

import sys
import subprocess

def main():
    # 转发到新的发布脚本
    script_path = "/root/.openclaw/workspace/skills/course-generator/scripts/publish_to_github.py"
    
    cmd = ['python3', script_path] + sys.argv[1:]
    
    result = subprocess.run(cmd)
    sys.exit(result.returncode)

if __name__ == '__main__':
    main()
