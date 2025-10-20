//
//  LifeApp.swift
//  Life
//
//  Created by tangxj on 10/13/25.
//

import SwiftUI
import SwiftData
import UserNotifications
import UIKit

@main
struct LifeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            DailyRecord.self,
            Matter.self,
            MatterRecord.self,
        ])
        
        // 使用更明确的配置，避免回退到内存存储
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // 如果持久化存储失败，尝试删除旧数据并重新创建
            print("SwiftData persistent container load failed: \(error)")
            print("Attempting to reset database...")
            
            // 删除旧的数据库文件
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let databaseURL = documentsPath.appendingPathComponent("default.store")
            
            do {
                try FileManager.default.removeItem(at: databaseURL)
                print("Old database removed, creating new one...")
                
                // 重新尝试创建容器
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                print("Failed to reset database: \(error)")
                // 最后的回退：使用内存存储，但会显示警告
                print("WARNING: Using in-memory storage - data will be lost on app restart!")
                let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                do {
                    return try ModelContainer(for: schema, configurations: [inMemoryConfig])
                } catch {
                    fatalError("Could not create ModelContainer: \(error)")
                }
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 清除推送通知角标
                    clearNotificationBadge()
                    
                    // 种子内置事项（仅首次或空数据时执行）
                    let context = sharedModelContainer.mainContext
                    BuiltInMatterSeeder.ensureSeeded(context: context)
                    
                    // 初始化提醒管理器
                    _ = ReminderManager.shared
                    
                    // 更新小组件数据
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        updateWidgetData(context: context)
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - 清除推送通知角标
    private func clearNotificationBadge() {
        DispatchQueue.main.async {
            // 使用新的推荐方法清除角标
            UNUserNotificationCenter.current().setBadgeCount(0) { error in
                if let error = error {
                    print("清除角标失败: \(error)")
                    // 如果新方法失败，回退到旧方法
                    DispatchQueue.main.async {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                } else {
                    print("✅ 角标已清除")
                }
            }
        }
    }
    
    // MARK: - 更新小组件数据
    private func updateWidgetData(context: ModelContext) {
        do {
            // 获取所有启用的事项
            let mattersDescriptor = FetchDescriptor<Matter>(
                predicate: #Predicate { $0.isEnabled },
                sortBy: [SortDescriptor(\.order)]
            )
            let matters = try context.fetch(mattersDescriptor)
            
            // 获取今日记录
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            let dailyRecordDescriptor = FetchDescriptor<DailyRecord>(
                predicate: #Predicate { record in
                    record.timestamp >= today && record.timestamp < tomorrow
                }
            )
            let dailyRecords = try context.fetch(dailyRecordDescriptor)
            let todayRecord = dailyRecords.first
            
            // 更新小组件
            WidgetDataManager.shared.updateTodayData(matters: matters, dailyRecord: todayRecord)
        } catch {
            print("更新小组件数据失败: \(error)")
        }
    }
}
