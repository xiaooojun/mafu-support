//
//  ReminderManager.swift
//  Life
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import UserNotifications
import SwiftUI
import Combine

// 提醒管理器 - 处理每日记录提醒
class ReminderManager: ObservableObject {
    static let shared = ReminderManager()
    
    @Published var isReminderEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isReminderEnabled, forKey: "isReminderEnabled")
            if isReminderEnabled {
                scheduleReminder()
            } else {
                cancelReminder()
            }
        }
    }
    
    @Published var reminderTime: Date = {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 20 // 默认晚上8点
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }() {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
            if isReminderEnabled {
                scheduleReminder()
            }
        }
    }
    
    private init() {
        loadSettings()
        requestNotificationPermission()
    }
    
    // 加载保存的设置
    private func loadSettings() {
        isReminderEnabled = UserDefaults.standard.bool(forKey: "isReminderEnabled")
        
        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            reminderTime = savedTime
        }
    }
    
    // 请求通知权限
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ 通知权限已授权")
                } else {
                    print("❌ 通知权限被拒绝")
                    self.isReminderEnabled = false
                }
            }
        }
    }
    
    // 检查通知权限状态
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // 安排提醒
    func scheduleReminder() {
        cancelReminder() // 先取消现有的提醒
        
        guard isReminderEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📝 生活记录提醒"
        content.body = "该记录今天的生活事项了，让每一天都值得回忆！"
        content.sound = .default
        content.badge = 1
        
        // 设置每日重复
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminderTime)
        let minute = calendar.component(.minute, from: reminderTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 安排提醒失败: \(error.localizedDescription)")
            } else {
                print("✅ 每日提醒已安排: \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    // 取消提醒
    func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
        print("🗑️ 已取消每日提醒")
    }
    
    // 获取提醒时间字符串
    func getReminderTimeString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: reminderTime)
    }
    
    // 测试通知（用于调试）
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🧪 测试通知"
        content.body = "这是一个测试通知，确认提醒功能正常工作"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "testNotification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 测试通知发送失败: \(error.localizedDescription)")
            } else {
                print("✅ 测试通知已发送")
            }
        }
    }
}
