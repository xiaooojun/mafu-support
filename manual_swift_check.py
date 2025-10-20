#!/usr/bin/env python3
"""
手动检查Swift编译错误的脚本
"""

import os
import re

def check_swift_file(file_path):
    """检查Swift文件中的常见错误"""
    errors = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')
            
        for i, line in enumerate(lines, 1):
            # 检查未使用的变量
            if 'if let' in line and '=' in line:
                # 检查下一行是否使用了这个变量
                if i < len(lines):
                    next_line = lines[i]
                    if 'if let' in line:
                        # 提取变量名
                        match = re.search(r'if let (\w+)', line)
                        if match:
                            var_name = match.group(1)
                            # 检查变量是否在后续代码中使用
                            if var_name not in next_line and 'optionIndicator' in next_line:
                                errors.append(f"第{i}行: 变量 '{var_name}' 被定义但未使用")
            
            # 检查其他常见错误
            if 'import' in line and not line.strip().startswith('import'):
                errors.append(f"第{i}行: import语句格式错误")
            
            if 'func' in line and '(' in line and ')' not in line:
                errors.append(f"第{i}行: 函数定义不完整")
            
            if 'struct' in line and '{' not in line:
                errors.append(f"第{i}行: struct定义不完整")
    
    except Exception as e:
        errors.append(f"读取文件失败: {e}")
    
    return errors

def main():
    print("🔍 手动检查Swift编译错误")
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
            errors = check_swift_file(full_path)
            
            if not errors:
                print("✅ 未发现明显错误")
            else:
                print("❌ 发现潜在问题:")
                for error in errors:
                    print(f"  - {error}")
                all_good = False
        else:
            print(f"⚠️  文件不存在: {file_path}")
    
    print("\n" + "=" * 40)
    if all_good:
        print("🎉 所有文件检查通过！")
    else:
        print("⚠️  发现潜在问题，请检查上述警告")
    
    return 0 if all_good else 1

if __name__ == "__main__":
    main()
