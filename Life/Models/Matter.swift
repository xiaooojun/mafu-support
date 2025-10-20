import Foundation
import SwiftData
import SwiftUI

// 统一的事项类型（复用现有 ModuleType，避免重复定义）
typealias MatterType = ModuleType

// 子项：标题 + 表情
struct MatterOption: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var emoji: String
    var title: String
    
    var displayText: String { emoji.isEmpty ? title : "\(emoji) \(title)" }
}

@Model
final class Matter {
    var id: UUID
    var title: String
    var icon: String
    var type: MatterType
    var isEnabled: Bool
    var isBuiltIn: Bool
    var order: Int
    var createdAt: Date
    var accentColorHex: String
    
    // 统一的子项（用于单选/多选）
    var options: [MatterOption]
    
    init(
        title: String,
        icon: String,
        type: MatterType,
        options: [MatterOption] = [],
        accentColorHex: String = "#007AFF",
        isBuiltIn: Bool = false,
        isEnabled: Bool = true,
        order: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.type = type
        self.options = options
        self.accentColorHex = accentColorHex
        self.isBuiltIn = isBuiltIn
        self.isEnabled = isEnabled
        self.order = order
        self.createdAt = Date()
    }
    
    var color: Color { Color(hex: accentColorHex) ?? .blue }
}

// 预置事项的种子工具（后续在 App 启动或需要时调用）
enum BuiltInMatterSeeder {
    static func ensureSeeded(context: ModelContext) {
        // 若已存在任一内置事项，则跳过
        if let existing = try? context.fetch(FetchDescriptor<Matter>()), existing.contains(where: { $0.isBuiltIn }) {
            return
        }
        
        // 从 UserDefaults 读取可能的自定义（兼容现有实现）
        func load(_ key: String, defaultValue: String) -> String {
            UserDefaults.standard.string(forKey: key) ?? defaultValue
        }
        func loadColor(_ key: String, defaultColorHex: String) -> String {
            if let hex = UserDefaults.standard.string(forKey: key), !hex.isEmpty { return hex }
            return defaultColorHex
        }
        
        // 心情（模板事项）
        let mood = Matter(
            title: load("predef_mood_title", defaultValue: "心情"),
            icon: load("predef_mood_icon", defaultValue: "heart.fill"),
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
            accentColorHex: loadColor("predef_mood_color", defaultColorHex: Color.red.toHex()),
            isBuiltIn: true,
            order: 0
        )
        // 睡眠（模板事项）
        let sleep = Matter(
            title: load("predef_sleep_title", defaultValue: "睡眠"),
            icon: load("predef_sleep_icon", defaultValue: "moon.stars.fill"),
            type: .singleSelect,
            options: [
                MatterOption(emoji: "😴", title: "很差"),
                MatterOption(emoji: "😪", title: "一般"),
                MatterOption(emoji: "😌", title: "还行"),
                MatterOption(emoji: "😊", title: "很好"),
                MatterOption(emoji: "✨", title: "非常好")
            ],
            accentColorHex: loadColor("predef_sleep_color", defaultColorHex: Color.indigo.toHex()),
            isBuiltIn: true,
            order: 1
        )
        // 健康
        let health = Matter(
            title: load("predef_health_title", defaultValue: "健康"),
            icon: load("predef_health_icon", defaultValue: "heart.fill"),
            type: .multiSelect,
            options: [],
            accentColorHex: loadColor("predef_health_color", defaultColorHex: Color.green.toHex()),
            isBuiltIn: true,
            order: 2
        )
        // 爱好
        let hobby = Matter(
            title: load("predef_hobby_title", defaultValue: "爱好"),
            icon: load("predef_hobby_icon", defaultValue: "star.fill"),
            type: .multiSelect,
            options: [],
            accentColorHex: loadColor("predef_hobby_color", defaultColorHex: Color.teal.toHex()),
            isBuiltIn: true,
            order: 3
        )
        
        context.insert(mood)
        context.insert(sleep)
        context.insert(health)
        context.insert(hobby)
        try? context.save()
    }
}

// 迁移：从旧的 CustomModule 转为 Matter（一次性）
enum MatterMigration {
    static func migrateFromCustomModules(context: ModelContext) {
        guard let customModules = try? context.fetch(FetchDescriptor<CustomModule>()) else { return }
        let existingMatters = (try? context.fetch(FetchDescriptor<Matter>())) ?? []
        let existingTitles = Set(existingMatters.map { $0.title })
        
        for module in customModules {
            // 若同名事项已存在则跳过（简易去重策略）
            if existingTitles.contains(module.title) { continue }
            
            let options: [MatterOption] = module.options.map { raw in
                let parsed = parse(raw)
                return MatterOption(emoji: parsed.emoji, title: parsed.title)
            }
            let matter = Matter(
                title: module.title,
                icon: module.icon,
                type: module.moduleType,
                options: options,
                accentColorHex: module.accentColor,
                isBuiltIn: false,
                isEnabled: module.isEnabled,
                order: module.order
            )
            context.insert(matter)
        }
        try? context.save()
    }
    
    private static func parse(_ display: String) -> (emoji: String, title: String) {
        let comps = display.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        if comps.count == 2, comps[0].count == 1 {
            return (String(comps[0]), String(comps[1]))
        }
        return ("", display)
    }
}


