import Foundation
import SwiftData
import SwiftUI
import UIKit

// 通用模块类型枚举
enum ModuleType: String, CaseIterable, Codable {
    case singleSelect = "single"      // 单选
    case multiSelect = "multi"       // 多选
    
    var displayName: String {
        switch self {
        case .singleSelect: return "单选"
        case .multiSelect: return "多选"
        }
    }
    
    var iconName: String {
        switch self {
        case .singleSelect: return "circle"
        case .multiSelect: return "checkmark.circle"
        }
    }
    
    var description: String {
        switch self {
        case .singleSelect: return "只能选择一个选项"
        case .multiSelect: return "可以选择多个选项"
        }
    }
}

// 通用模块配置
@Model
final class CustomModule {
    var id: UUID
    var title: String
    var icon: String
    var moduleType: ModuleType
    var isEnabled: Bool
    var order: Int
    var createdAt: Date
    
    // 选项配置（用于单选/多选）
    var options: [String]
    
    // 颜色主题
    var accentColor: String // 存储颜色的十六进制值
    
    init(title: String, icon: String, moduleType: ModuleType, options: [String] = [], accentColor: String = "#007AFF") {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.moduleType = moduleType
        self.isEnabled = true
        self.order = 0
        self.createdAt = Date()
        self.options = options
        self.accentColor = accentColor
    }
    
    // 获取颜色
    var color: Color {
        Color(hex: accentColor) ?? .blue
    }
}

// 用户选择的记录
@Model
final class ModuleRecord {
    var id: UUID
    var moduleId: UUID
    var date: Date
    var selectedOptions: [String] // 多选时的选项
    var singleOption: String? // 单选时的选项
    var textValue: String? // 文本输入的值
    var numberValue: Double? // 数字输入的值
    var dateValue: Date? // 日期选择的值
    var createdAt: Date
    
    init(moduleId: UUID, date: Date = Date()) {
        self.id = UUID()
        self.moduleId = moduleId
        self.date = Calendar.current.startOfDay(for: date)
        self.selectedOptions = []
        self.singleOption = nil
        self.textValue = nil
        self.numberValue = nil
        self.dateValue = nil
        self.createdAt = Date()
    }
}

// Color扩展，支持十六进制颜色
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255) << 0
        return String(format: "#%06x", rgb)
        #else
        // macOS 版本
        let nsColor = NSColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255) << 0
        return String(format: "#%06x", rgb)
        #endif
    }
}

// 通知名称扩展
extension Notification.Name {
    static let predefMetaChanged = Notification.Name("predefMetaChanged")
}
