//
//  LogoManager.swift
//  Life
//
//  Created by tangxj on 10/13/25.
//

import SwiftUI
import UIKit
import Combine

class LogoManager: ObservableObject {
    static let shared = LogoManager()
    
    @Published var currentLogoType: LogoType = .dots {
        didSet {
            UserDefaults.standard.set(currentLogoType.rawValue, forKey: "selectedLogoType")
            // 只有在非初始化状态下才更新图标
            if !isInitializing {
                updateAppIcon()
            }
        }
    }
    
    private var isInitializing = true
    
    private init() {
        if let savedType = UserDefaults.standard.string(forKey: "selectedLogoType"),
           let logoType = LogoType(rawValue: savedType) {
            currentLogoType = logoType
        }
        // 初始化完成后，允许后续的图标更新
        isInitializing = false
    }
    
    func updateAppIcon() {
        // 动态更新应用图标
        print("🔄 Logo类型已更改为: \(currentLogoType.displayName)")
        
        // 检查是否支持Alternate Icons
        guard UIApplication.shared.supportsAlternateIcons else {
            print("❌ 设备不支持Alternate Icons功能")
            return
        }
        
        // 根据logo类型设置对应的图标
        let iconName: String? = {
            switch currentLogoType {
            case .dots:
                return nil // 使用默认图标
            case .calendar:
                return "Calendar"
            case .chart:
                return "Chart"
            }
        }()
        
        print("🔄 尝试设置图标: \(iconName ?? "默认图标")")
        
        // 异步设置图标
        Task { @MainActor in
            do {
                try await UIApplication.shared.setAlternateIconName(iconName)
                print("✅ 应用图标已更改为: \(currentLogoType.displayName)")
            } catch {
                print("❌ 更改应用图标失败: \(error.localizedDescription)")
                print("❌ 错误详情: \(error)")
            }
        }
    }
    
    func getCurrentLogoView() -> AnyView {
        switch currentLogoType {
        case .dots:
            return AnyView(AppIconDesign())
        case .calendar:
            return AnyView(AppIconDesignCalendar())
        case .chart:
            return AnyView(AppIconDesignChart())
        }
    }
    
    func getCurrentLogoViewDark() -> AnyView {
        switch currentLogoType {
        case .dots:
            return AnyView(AppIconDesignDark())
        case .calendar:
            return AnyView(AppIconDesignCalendarDark())
        case .chart:
            return AnyView(AppIconDesignChartDark())
        }
    }
}

// 扩展：为不同的logo类型提供PNG生成功能
extension LogoManager {
    func generatePNGForCurrentLogo(isDark: Bool = false) -> UIImage? {
        let logoView = isDark ? getCurrentLogoViewDark() : getCurrentLogoView()
        
        let renderer = ImageRenderer(content: logoView)
        renderer.scale = 1.0
        
        return renderer.uiImage
    }
    
    func saveCurrentLogoAsPNG(isDark: Bool = false) {
        guard let image = generatePNGForCurrentLogo(isDark: isDark) else { return }
        
        // 保存到相册
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("当前Logo已保存到相册")
    }
}
