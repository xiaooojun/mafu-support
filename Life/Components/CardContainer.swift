//
//  CardContainer.swift
//  Life
//
//  Created by tangxj on 10/13/25.
//

import SwiftUI
import UIKit

// MARK: - 卡片容器
struct CardContainer<Content: View>: View {
    let title: String
    var leadingIcon: String? = nil
    var accentColor: Color = .blue
    var onEdit: (() -> Void)? = nil
    var onClear: (() -> Void)? = nil
    var onHistory: (() -> Void)? = nil
    var onAddTestData: (() -> Void)? = nil
    let content: Content
    var fixedHeight: CGFloat?
    
    init(title: String,
         leadingIcon: String? = nil,
         accentColor: Color = .blue,
         onEdit: (() -> Void)? = nil,
         onClear: (() -> Void)? = nil,
         onHistory: (() -> Void)? = nil,
         onAddTestData: (() -> Void)? = nil,
         fixedHeight: CGFloat? = nil,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.leadingIcon = leadingIcon
        self.accentColor = accentColor
        self.onEdit = onEdit
        self.onClear = onClear
        self.onHistory = onHistory
        self.onAddTestData = onAddTestData
        self.content = content()
        self.fixedHeight = fixedHeight
    }
    
    var body: some View {
        ZStack {
            // 外层卡片
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
            VStack(spacing: 0) {
                // 新样式标题栏：渐变+仅上圆角
                ZStack {
                    LinearGradient(colors: [accentColor, accentColor.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                        .frame(height: 46)
                    HStack(spacing: 10) {
                        if let leadingIcon {
                            Image(systemName: leadingIcon)
                                .foregroundColor(.white.opacity(0.95))
                        }
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        if let onHistory {
                            CircleButton(symbol: "chart.line.uptrend.xyaxis", action: onHistory)
                        }
                        if let onAddTestData {
                            CircleButton(symbol: "plus.circle.fill", action: onAddTestData)
                        }
                        if let onEdit {
                            CircleButton(symbol: "pencil", action: onEdit)
                        }
                        if let onClear {
                            CircleButton(symbol: "trash", action: onClear)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                // 内容
                VStack(alignment: .leading, spacing: 12) {
                    content
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight]))
            }
        }
        .frame(height: fixedHeight)
    }
}

// 顶栏右上角的小圆形图标按钮
private struct CircleButton: View {
    let symbol: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.white.opacity(0.15))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// 仅对指定角应用圆角
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    #if canImport(UIKit)
    var corners: UIRectCorner = .allCorners
    #else
    var corners: RectCorner = .allCorners
    #endif
    
    func path(in rect: CGRect) -> Path {
        #if canImport(UIKit)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
        #else
        // macOS 版本 - 使用 SwiftUI 的 RoundedRectangle
        return Path { path in
            let cornerRadius = min(radius, min(rect.width, rect.height) / 2)
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        }
        #endif
    }
}

#if !canImport(UIKit)
// macOS 版本的 RectCorner
struct RectCorner: OptionSet {
    let rawValue: Int
    
    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)
    
    static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}
#endif
