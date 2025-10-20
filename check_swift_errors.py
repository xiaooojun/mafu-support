#!/usr/bin/env python3
"""
检查Swift编译错误的脚本
"""

import os
import subprocess
import sys

def check_swift_syntax(file_path):
    """检查Swift文件语法"""
    try:
        # 使用swiftc检查语法
        result = subprocess.run(['swiftc', '-parse', file_path], 
                              capture_output=True, text=True, 
                              cwd='/Users/tangxiaojun/Downloads/Life')
        return result.returncode == 0, result.stderr
    except Exception as e:
        return False, str(e)

def main():
    print("🔍 检查Swift编译错误")
    print("=" * 40)
    
    # 检查主要文件
    files_to_check = [
        'Life/Views/MatterHistoryView.swift',
        'Life/Views/OptionConfigView.swift', 
        'Life/Views/MatterEditView.swift',
        'Life/LifeApp.swift'
    ]
    
    all_good = True
    
    for file_path in files_to_check:
        full_path = os.path.join('/Users/tangxiaojun/Downloads/Life', file_path)
        if os.path.exists(full_path):
            print(f"\n📄 检查: {file_path}")
            is_valid, error = check_swift_syntax(full_path)
            
            if is_valid:
                print("✅ 语法正确")
            else:
                print("❌ 发现错误:")
                print(error)
                all_good = False
        else:
            print(f"⚠️  文件不存在: {file_path}")
    
    print("\n" + "=" * 40)
    if all_good:
        print("🎉 所有文件语法检查通过！")
    else:
        print("⚠️  发现编译错误，请修复上述问题")
    
    return 0 if all_good else 1

if __name__ == "__main__":
    sys.exit(main())
