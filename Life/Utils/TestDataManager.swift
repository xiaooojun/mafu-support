import SwiftUI
import SwiftData
import Foundation
import Combine

class TestDataManager: ObservableObject {
    static let shared = TestDataManager()
    
    private init() {}
    
    // 生成测试数据
    func generateTestData(modelContext: ModelContext) {
        // 先清除现有数据
        clearAllData(modelContext: modelContext)
        
        // 创建测试事项
        let testMatters = createTestMatters()
        
        // 插入事项
        for matter in testMatters {
            modelContext.insert(matter)
        }
        
        // 生成一个月的测试记录
        generateOneMonthRecords(modelContext: modelContext, matters: testMatters)
        
        // 保存数据
        do {
            try modelContext.save()
            print("✅ 测试数据生成成功")
        } catch {
            print("❌ 测试数据生成失败: \(error)")
        }
    }
    
    // 创建测试事项
    private func createTestMatters() -> [Matter] {
        return [
            // 心情记录
            Matter(
                title: "心情",
                icon: "heart.fill",
                type: .singleSelect,
                options: [
                    MatterOption(emoji: "😢", title: "很糟糕"),
                    MatterOption(emoji: "😔", title: "不太好"),
                    MatterOption(emoji: "😐", title: "一般"),
                    MatterOption(emoji: "🙂", title: "还行"),
                    MatterOption(emoji: "😊", title: "还不错"),
                    MatterOption(emoji: "😄", title: "开心"),
                    MatterOption(emoji: "🤩", title: "非常开心")
                ],
                accentColorHex: Color.red.toHex()
            ),
            
            // 睡眠质量
            Matter(
                title: "睡眠",
                icon: "moon.stars.fill",
                type: .singleSelect,
                options: [
                    MatterOption(emoji: "😴", title: "很差"),
                    MatterOption(emoji: "😪", title: "一般"),
                    MatterOption(emoji: "😌", title: "还行"),
                    MatterOption(emoji: "😊", title: "很好"),
                    MatterOption(emoji: "✨", title: "非常好")
                ],
                accentColorHex: Color.indigo.toHex()
            ),
            
            // 工作效率
            Matter(
                title: "工作效率",
                icon: "briefcase.fill",
                type: .singleSelect,
                options: [
                    MatterOption(emoji: "😫", title: "很低"),
                    MatterOption(emoji: "😐", title: "一般"),
                    MatterOption(emoji: "🙂", title: "不错"),
                    MatterOption(emoji: "😊", title: "很好"),
                    MatterOption(emoji: "🚀", title: "高效")
                ],
                accentColorHex: Color.blue.toHex()
            ),
            
            // 运动强度
            Matter(
                title: "运动强度",
                icon: "figure.run",
                type: .singleSelect,
                options: [
                    MatterOption(emoji: "😴", title: "无运动"),
                    MatterOption(emoji: "🚶", title: "轻度"),
                    MatterOption(emoji: "🏃", title: "中度"),
                    MatterOption(emoji: "💪", title: "高强度"),
                    MatterOption(emoji: "🔥", title: "极限")
                ],
                accentColorHex: Color.orange.toHex()
            ),
            
            // 饮食质量
            Matter(
                title: "饮食质量",
                icon: "fork.knife",
                type: .singleSelect,
                options: [
                    MatterOption(emoji: "🍔", title: "不健康"),
                    MatterOption(emoji: "🍕", title: "一般"),
                    MatterOption(emoji: "🥗", title: "还行"),
                    MatterOption(emoji: "🥙", title: "健康"),
                    MatterOption(emoji: "🥑", title: "很健康")
                ],
                accentColorHex: Color.purple.toHex()
            )
        ]
    }
    
    // 生成一个月的记录
    private func generateOneMonthRecords(modelContext: ModelContext, matters: [Matter]) {
        let calendar = Calendar.current
        let today = Date()
        
        // 生成过去30天的数据
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            for matter in matters {
                // 在生成记录之前，先保存matter的关键属性
                let matterId = matter.id
                let matterTitle = matter.title
                let matterType = matter.type
                
                // 为每个事项生成记录
                let record = generateRecordForMatter(
                    matterId: matterId,
                    matterTitle: matterTitle,
                    matterType: matterType,
                    date: date
                )
                modelContext.insert(record)
            }
        }
    }
    
    // 为特定事项生成记录
    private func generateRecordForMatter(matterId: UUID, matterTitle: String, matterType: MatterType, date: Date) -> MatterRecord {
        let selectedOptions: [MatterOption]
        
        switch matterTitle {
        case "心情":
            // 心情：模拟真实的心情波动
            selectedOptions = generateMoodOptions(date: date)
        case "睡眠":
            // 睡眠：工作日和周末不同
            selectedOptions = generateSleepOptions(date: date)
        case "工作效率":
            // 工作效率：工作日较高，周末较低
            selectedOptions = generateWorkEfficiencyOptions(date: date)
        case "运动强度":
            // 运动：随机分布，但有一定规律
            selectedOptions = generateExerciseOptions(date: date)
        case "饮食质量":
            // 饮食：相对稳定，偶尔波动
            selectedOptions = generateDietOptions(date: date)
        default:
            // 对于其他情况，使用默认选项
            selectedOptions = [MatterOption(emoji: "😐", title: "一般")]
        }
        
        let record = MatterRecord(matterId: matterId, date: date)
        
        // 设置选中的选项
        if matterType == .singleSelect {
            record.singleOptionId = selectedOptions.first?.id
        } else {
            record.selectedOptionIds = selectedOptions.map { $0.id }
        }
        
        return record
    }
    
    // 生成心情选项（模拟真实波动）
    private func generateMoodOptions(date: Date) -> [MatterOption] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let isWeekend = weekday == 1 || weekday == 7
        
        // 周末心情通常更好
        let moodOptions = [
            "😢", "😔", "😐", "🙂", "😊", "😄", "🤩"
        ]
        
        let weights: [Double]
        if isWeekend {
            // 周末：偏向好心情
            weights = [0.05, 0.1, 0.15, 0.2, 0.25, 0.2, 0.05]
        } else {
            // 工作日：相对平均
            weights = [0.1, 0.15, 0.2, 0.2, 0.2, 0.1, 0.05]
        }
        
        let selectedEmoji = weightedRandomSelection(from: moodOptions, weights: weights)
        return [MatterOption(emoji: selectedEmoji, title: getMoodTitle(for: selectedEmoji))]
    }
    
    // 生成睡眠选项
    private func generateSleepOptions(date: Date) -> [MatterOption] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let isWeekend = weekday == 1 || weekday == 7
        
        let sleepOptions = ["😴", "😪", "😌", "😊", "✨"]
        let weights: [Double]
        
        if isWeekend {
            // 周末：睡眠质量更好
            weights = [0.05, 0.1, 0.2, 0.35, 0.3]
        } else {
            // 工作日：睡眠质量一般
            weights = [0.1, 0.2, 0.3, 0.25, 0.15]
        }
        
        let selectedEmoji = weightedRandomSelection(from: sleepOptions, weights: weights)
        return [MatterOption(emoji: selectedEmoji, title: getSleepTitle(for: selectedEmoji))]
    }
    
    // 生成工作效率选项
    private func generateWorkEfficiencyOptions(date: Date) -> [MatterOption] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let isWeekend = weekday == 1 || weekday == 7
        
        let workOptions = ["😫", "😐", "🙂", "😊", "🚀"]
        let weights: [Double]
        
        if isWeekend {
            // 周末：工作效率低
            weights = [0.3, 0.4, 0.2, 0.08, 0.02]
        } else {
            // 工作日：工作效率较高
            weights = [0.05, 0.15, 0.3, 0.35, 0.15]
        }
        
        let selectedEmoji = weightedRandomSelection(from: workOptions, weights: weights)
        return [MatterOption(emoji: selectedEmoji, title: getWorkTitle(for: selectedEmoji))]
    }
    
    // 生成运动选项
    private func generateExerciseOptions(date: Date) -> [MatterOption] {
        let exerciseOptions = ["😴", "🚶", "🏃", "💪", "🔥"]
        let weights = [0.2, 0.3, 0.25, 0.2, 0.05] // 大部分是轻度到中度运动
        
        let selectedEmoji = weightedRandomSelection(from: exerciseOptions, weights: weights)
        return [MatterOption(emoji: selectedEmoji, title: getExerciseTitle(for: selectedEmoji))]
    }
    
    // 生成饮食选项
    private func generateDietOptions(date: Date) -> [MatterOption] {
        let dietOptions = ["🍔", "🍕", "🥗", "🥙", "🥑"]
        let weights = [0.1, 0.2, 0.3, 0.3, 0.1] // 偏向健康饮食
        
        let selectedEmoji = weightedRandomSelection(from: dietOptions, weights: weights)
        return [MatterOption(emoji: selectedEmoji, title: getDietTitle(for: selectedEmoji))]
    }
    
    // 生成备注
    private func generateNote(for matterTitle: String, date: Date) -> String {
        let notes = [
            "今天感觉不错",
            "需要调整一下",
            "继续保持",
            "有点累了",
            "状态很好",
            "明天加油",
            "今天很充实",
            "有点压力",
            "放松一下",
            "很满意"
        ]
        return notes.randomElement() ?? ""
    }
    
    // 加权随机选择
    private func weightedRandomSelection<T>(from items: [T], weights: [Double]) -> T {
        let totalWeight = weights.reduce(0, +)
        let randomValue = Double.random(in: 0...totalWeight)
        
        var currentWeight = 0.0
        for (index, weight) in weights.enumerated() {
            currentWeight += weight
            if randomValue <= currentWeight {
                return items[index]
            }
        }
        
        return items.last!
    }
    
    // 辅助方法：获取各种标题
    private func getMoodTitle(for emoji: String) -> String {
        switch emoji {
        case "😢": return "很糟糕"
        case "😔": return "不太好"
        case "😐": return "一般"
        case "🙂": return "还行"
        case "😊": return "还不错"
        case "😄": return "开心"
        case "🤩": return "非常开心"
        default: return "一般"
        }
    }
    
    private func getSleepTitle(for emoji: String) -> String {
        switch emoji {
        case "😴": return "很差"
        case "😪": return "一般"
        case "😌": return "还行"
        case "😊": return "很好"
        case "✨": return "非常好"
        default: return "一般"
        }
    }
    
    private func getWorkTitle(for emoji: String) -> String {
        switch emoji {
        case "😫": return "很低"
        case "😐": return "一般"
        case "🙂": return "不错"
        case "😊": return "很好"
        case "🚀": return "高效"
        default: return "一般"
        }
    }
    
    private func getExerciseTitle(for emoji: String) -> String {
        switch emoji {
        case "😴": return "无运动"
        case "🚶": return "轻度"
        case "🏃": return "中度"
        case "💪": return "高强度"
        case "🔥": return "极限"
        default: return "轻度"
        }
    }
    
    private func getDietTitle(for emoji: String) -> String {
        switch emoji {
        case "🍔": return "不健康"
        case "🍕": return "一般"
        case "🥗": return "还行"
        case "🥙": return "健康"
        case "🥑": return "很健康"
        default: return "一般"
        }
    }
    
    // 清除所有数据
    private func clearAllData(modelContext: ModelContext) {
        // 删除所有记录
        let recordDescriptor = FetchDescriptor<MatterRecord>()
        let records = try? modelContext.fetch(recordDescriptor)
        records?.forEach { modelContext.delete($0) }
        
        // 删除所有事项
        let matterDescriptor = FetchDescriptor<Matter>()
        let matters = try? modelContext.fetch(matterDescriptor)
        matters?.forEach { modelContext.delete($0) }
        
        try? modelContext.save()
    }
}
