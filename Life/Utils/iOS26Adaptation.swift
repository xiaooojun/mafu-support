//
//  iOS26Adaptation.swift
//  Life
//
//  Created by tangxj on 10/16/25.
//

import SwiftUI
import UIKit

// MARK: - iOS 26 适配工具类
struct iOS26Adaptation {
    
    // MARK: - 安全区域适配
    static func getSafeAreaInsets() -> EdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return EdgeInsets()
        }
        let uiInsets = window.safeAreaInsets
        return EdgeInsets(top: uiInsets.top, leading: uiInsets.left, bottom: uiInsets.bottom, trailing: uiInsets.right)
    }
    
    // MARK: - 动态岛设备检测
    static var hasDynamicIsland: Bool {
        let safeAreaInsets = getSafeAreaInsets()
        return safeAreaInsets.top > 44 // 动态岛设备顶部安全区域通常大于44
    }
    
    // MARK: - 触觉反馈
    static func lightHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func mediumHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    static func heavyHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - 导航栏外观配置
    static func configureNavigationBarAppearance(
        backgroundColor: Color,
        titleColor: Color = .primary,
        largeTitleFont: Font? = nil,
        regularTitleFont: Font? = nil
    ) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(backgroundColor)
        appearance.shadowColor = .clear
        
        // 设置标题样式
        let largeFont = largeTitleFont ?? Font.system(size: 34, weight: .bold)
        let regularFont = regularTitleFont ?? Font.system(size: 17, weight: .semibold)
        
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor(titleColor)
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor(titleColor)
        ]
        
        // iOS 26 优化：确保标题始终可见
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().prefersLargeTitles = true
        
        // iOS 26 新特性：强制显示标题
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = UIColor(backgroundColor)
    }
    
    // MARK: - TabBar高度计算
    static func calculateTabBarHeight(baseHeight: CGFloat = 56) -> CGFloat {
        let safeAreaInsets = getSafeAreaInsets()
        return baseHeight + max(safeAreaInsets.bottom, 0)
    }
    
    // MARK: - 设备类型检测
    static var deviceType: DeviceType {
        let safeAreaInsets = getSafeAreaInsets()
        
        if safeAreaInsets.top > 44 {
            return .dynamicIsland
        } else if safeAreaInsets.top > 20 {
            return .notch
        } else {
            return .classic
        }
    }
    
    enum DeviceType {
        case classic      // iPhone 8及以下
        case notch       // iPhone X系列
        case dynamicIsland // iPhone 14 Pro系列及更新
    }
}

// MARK: - iOS 26 适配修饰符
struct iOS26AdaptationModifier: ViewModifier {
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                iOS26Adaptation.configureNavigationBarAppearance(
                    backgroundColor: backgroundColor
                )
            }
    }
}

extension View {
    func iOS26Adaptation(backgroundColor: Color = Color.gray.opacity(0.1)) -> some View {
        modifier(iOS26AdaptationModifier(backgroundColor: backgroundColor))
    }
}

// MARK: - iOS 26 触觉反馈按钮
struct HapticButton<Label: View>: View {
    let action: () -> Void
    let label: () -> Label
    
    #if canImport(UIKit)
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    
    init(
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.hapticStyle = hapticStyle
        self.label = label
    }
    #else
    init(
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.label = label
    }
    #endif
    
    var body: some View {
        Button(action: {
            #if canImport(UIKit)
            let impactFeedback = UIImpactFeedbackGenerator(style: hapticStyle)
            impactFeedback.impactOccurred()
            #endif
            action()
        }, label: label)
    }
}

// MARK: - iOS 26 动态TabBar
struct DynamicTabBar: View {
    @Binding var selection: Int
    let tabs: [TabItem]
    let backgroundColor: Color
    
    struct TabItem {
        let icon: String
        let title: String
        let tag: Int
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
                ForEach(tabs, id: \.tag) { tab in
                    tabButton(tab: tab)
                }
            }
            .frame(height: 马夫.iOS26Adaptation.calculateTabBarHeight())
            .background(backgroundColor.ignoresSafeArea(edges: .bottom))
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 0.5)
                    .frame(maxHeight: .infinity, alignment: .top)
            )
        }
    }
    
    @ViewBuilder
    private func tabButton(tab: TabItem) -> some View {
        #if canImport(UIKit)
        HapticButton(hapticStyle: .light, action: {
            selection = tab.tag
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .scaleEffect(selection == tab.tag ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: selection)
                Text(tab.title)
                    .font(.footnote)
                    .fontWeight(selection == tab.tag ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(selection == tab.tag ? .blue : .secondary)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        #else
        Button(action: {
            selection = tab.tag
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .scaleEffect(selection == tab.tag ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: selection)
                Text(tab.title)
                    .font(.footnote)
                    .fontWeight(selection == tab.tag ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(selection == tab.tag ? .blue : .secondary)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        #endif
    }
}
