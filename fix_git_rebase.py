#!/usr/bin/env python3
"""
Git变基撤销脚本
处理git变基撤销操作
"""

import subprocess
import os
import sys

def run_git_command(command):
    """执行git命令"""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, cwd='/Users/tangxiaojun/Downloads/Life')
        return result.returncode, result.stdout, result.stderr
    except Exception as e:
        return -1, "", str(e)

def main():
    print("🔧 Git变基撤销工具")
    print("=" * 50)
    
    # 检查是否在git仓库中
    returncode, stdout, stderr = run_git_command("git status")
    if returncode != 0:
        print("❌ 错误：不在git仓库中或git命令失败")
        print(f"错误信息：{stderr}")
        return
    
    print("✅ 成功连接到git仓库")
    
    # 显示当前状态
    print("\n📊 当前git状态：")
    returncode, stdout, stderr = run_git_command("git status --porcelain")
    if returncode == 0:
        if stdout.strip():
            print("有未提交的更改：")
            print(stdout)
        else:
            print("工作目录干净")
    
    # 显示分支信息
    print("\n🌿 分支信息：")
    returncode, stdout, stderr = run_git_command("git branch -v")
    if returncode == 0:
        print(stdout)
    
    # 显示reflog
    print("\n📝 最近的git操作历史：")
    returncode, stdout, stderr = run_git_command("git reflog --oneline -10")
    if returncode == 0:
        print(stdout)
    else:
        print(f"无法获取reflog：{stderr}")
    
    # 检查ORIG_HEAD
    print("\n🔍 检查ORIG_HEAD：")
    if os.path.exists('/Users/tangxiaojun/Downloads/Life/.git/ORIG_HEAD'):
        returncode, stdout, stderr = run_git_command("git log --oneline ORIG_HEAD -1")
        if returncode == 0:
            print(f"ORIG_HEAD指向：{stdout.strip()}")
        else:
            print("无法读取ORIG_HEAD")
    else:
        print("ORIG_HEAD不存在")
    
    print("\n🔄 撤销变基选项：")
    print("1. 使用ORIG_HEAD撤销变基")
    print("2. 使用reflog撤销变基")
    print("3. 手动指定提交哈希")
    print("4. 退出")
    
    choice = input("\n请选择操作 (1-4): ").strip()
    
    if choice == "1":
        # 使用ORIG_HEAD撤销
        if os.path.exists('/Users/tangxiaojun/Downloads/Life/.git/ORIG_HEAD'):
            print("\n🔄 使用ORIG_HEAD撤销变基...")
            returncode, stdout, stderr = run_git_command("git reset --hard ORIG_HEAD")
            if returncode == 0:
                print("✅ 成功撤销变基")
                print(stdout)
            else:
                print(f"❌ 撤销失败：{stderr}")
        else:
            print("❌ ORIG_HEAD不存在，无法使用此方法")
    
    elif choice == "2":
        # 使用reflog撤销
        print("\n📝 最近的reflog条目：")
        returncode, stdout, stderr = run_git_command("git reflog --oneline -20")
        if returncode == 0:
            print(stdout)
            commit_hash = input("\n请输入要重置到的提交哈希（或reflog编号如HEAD@{2}）: ").strip()
            if commit_hash:
                print(f"\n🔄 重置到 {commit_hash}...")
                returncode, stdout, stderr = run_git_command(f"git reset --hard {commit_hash}")
                if returncode == 0:
                    print("✅ 成功重置")
                    print(stdout)
                else:
                    print(f"❌ 重置失败：{stderr}")
        else:
            print(f"❌ 无法获取reflog：{stderr}")
    
    elif choice == "3":
        # 手动指定提交哈希
        commit_hash = input("\n请输入要重置到的提交哈希: ").strip()
        if commit_hash:
            print(f"\n🔄 重置到 {commit_hash}...")
            returncode, stdout, stderr = run_git_command(f"git reset --hard {commit_hash}")
            if returncode == 0:
                print("✅ 成功重置")
                print(stdout)
            else:
                print(f"❌ 重置失败：{stderr}")
    
    elif choice == "4":
        print("👋 退出")
        return
    
    else:
        print("❌ 无效选择")
        return
    
    # 显示最终状态
    print("\n📊 最终状态：")
    returncode, stdout, stderr = run_git_command("git status")
    if returncode == 0:
        print(stdout)
    
    print("\n🎉 操作完成！")

if __name__ == "__main__":
    main()
