//
//  WidgetDataManager.swift
//  Life
//
//  Created by tangxj on 10/15/25.
//

import Foundation
import SwiftData
import WidgetKit
import SwiftUI

// MARK: - 小组件数据模型
struct MatterSummary: Codable {
    let id: String
    let title: String
    let icon: String
    let color: String
    let completedCount: Int
    let totalCount: Int
    let isCompleted: Bool
}

struct TodayWidgetData: Codable {
    let date: Date
    let matters: [MatterSummary]
    let summary: String?
    let mood: String?
}

// MARK: - 小组件数据管理器
class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.xj.life.widget")
    
    private init() {}
    
    // MARK: - 保存今日数据到小组件
    func updateTodayData(matters: [Matter], dailyRecord: DailyRecord?) {
        let matterSummaries = matters.map { matter in
            MatterSummary(
                id: matter.id.uuidString,
                title: matter.title,
                icon: matter.icon,
                color: matter.color.toHexString(),
                completedCount: getCompletedCount(for: matter),
                totalCount: matter.options.count,
                isCompleted: isMatterCompleted(matter)
            )
        }
        
        let widgetData = TodayWidgetData(
            date: Date(),
            matters: matterSummaries,
            summary: dailyRecord?.summary,
            mood: dailyRecord?.mood
        )
        
        // 保存到UserDefaults
        if let data = try? JSONEncoder().encode(widgetData) {
            userDefaults?.set(data, forKey: "todayWidgetData")
        }
        
        // 通知小组件更新
        WidgetCenter.shared.reloadTimelines(ofKind: "TodayWidget")
    }
    
    // MARK: - 从小组件获取数据
    func getTodayData() -> TodayWidgetData? {
        guard let data = userDefaults?.data(forKey: "todayWidgetData"),
              let widgetData = try? JSONDecoder().decode(TodayWidgetData.self, from: data) else {
            return nil
        }
        return widgetData
    }
    
    // MARK: - 辅助方法
    private func getCompletedCount(for matter: Matter) -> Int {
        // 这里需要根据实际的数据模型来计算完成数量
        // 暂时返回随机值用于演示
        return Int.random(in: 0...matter.options.count)
    }
    
    private func isMatterCompleted(_ matter: Matter) -> Bool {
        // 判断事项是否完成
        return getCompletedCount(for: matter) == matter.options.count
    }
}

// MARK: - 颜色扩展
extension Color {
    func toHexString() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255) << 0
        return String(format: "#%06x", rgb)
    }
}
