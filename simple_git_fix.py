#!/usr/bin/env python3
"""
简单的git变基撤销脚本
"""

import subprocess
import os

def execute_command(command):
    """执行命令"""
    try:
        # 使用os.system作为备选方案
        result = os.system(command)
        return result == 0
    except:
        return False

def main():
    print("🔧 Git变基撤销工具")
    print("=" * 30)
    
    # 切换到正确的目录
    os.chdir('/Users/tangxiaojun/Downloads/Life')
    
    print("📁 当前目录:", os.getcwd())
    
    # 检查ORIG_HEAD是否存在
    if os.path.exists('.git/ORIG_HEAD'):
        print("✅ 找到ORIG_HEAD，可以撤销变基")
        
        # 读取ORIG_HEAD内容
        with open('.git/ORIG_HEAD', 'r') as f:
            orig_head = f.read().strip()
        print(f"📍 ORIG_HEAD指向: {orig_head}")
        
        # 执行撤销变基
        print("\n🔄 正在撤销变基...")
        command = f"git reset --hard {orig_head}"
        print(f"执行命令: {command}")
        
        success = execute_command(command)
        
        if success:
            print("✅ 变基撤销成功！")
        else:
            print("❌ 变基撤销失败")
            
        # 显示当前状态
        print("\n📊 当前状态:")
        execute_command("git status")
        
    else:
        print("❌ 未找到ORIG_HEAD，可能变基操作已经完成很久")
        print("💡 建议使用 git reflog 查看历史操作")

if __name__ == "__main__":
    main()
