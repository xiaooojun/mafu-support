//
//  SettingsView.swift
//  Life
//
//  Created by tangxj on 10/13/25.
//

import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @StateObject private var logoManager = LogoManager.shared
    @StateObject private var reminderManager = ReminderManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingPermissionAlert = false
    @State private var showingCardSettings = false
    
    var body: some View {
        NavigationView {
            List {
                Section("卡片管理") {
                    Button(action: {
                        showingCardSettings = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.stack.fill")
                                .foregroundColor(.blue)
                            Text("卡片显示设置")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Text("管理首页卡片的显示状态和顺序")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                Section("应用图标") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(LogoType.allCases, id: \.self) { logoType in
                                HorizontalLogoCard(
                                    logoType: logoType,
                                    isSelected: logoManager.currentLogoType == logoType
                                ) {
                                    logoManager.currentLogoType = logoType
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 120)
                }
                
                Section("提醒设置") {
                    // 提醒开关
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                        Text("每日记录提醒")
                        Spacer()
                        Toggle("", isOn: $reminderManager.isReminderEnabled)
                            .onChange(of: reminderManager.isReminderEnabled) { _, enabled in
                                if enabled {
                                    checkNotificationPermission()
                                }
                            }
                    }
                    
                    // 提醒时间设置
                    if reminderManager.isReminderEnabled {
                        // 系统原生时间选择器（24小时制）
                        DatePicker("提醒时间", selection: $reminderManager.reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .environment(\.locale, Locale(identifier: "zh_CN"))
                        
                        // 测试通知按钮
                        Button(action: {
                            reminderManager.sendTestNotification()
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.green)
                                Text("发送测试通知")
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section("关于") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("生活记录")
                        Spacer()
                        Text("记录生活的美好")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCardSettings) {
                CardSettingsView()
            }
            .alert("需要通知权限", isPresented: $showingPermissionAlert) {
                Button("去设置") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("取消", role: .cancel) {
                    reminderManager.isReminderEnabled = false
                }
            } message: {
                Text("为了发送每日记录提醒，需要在系统设置中开启通知权限。")
            }
        }
    }
    
    // 检查通知权限
    private func checkNotificationPermission() {
        reminderManager.checkNotificationPermission { granted in
            if !granted {
                DispatchQueue.main.async {
                    showingPermissionAlert = true
                }
            }
        }
    }
}

struct HorizontalLogoCard: View {
    let logoType: LogoType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Logo预览
                ZStack {
                    LogoPreview(logoType: logoType)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // 选中状态覆盖层
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 3)
                            .frame(width: 60, height: 60)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .font(.caption)
                            }
                        }
                        .frame(width: 60, height: 60)
                    }
                }
                
                // 文字信息
                VStack(spacing: 2) {
                    Text(logoType.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(logoDescription(for: logoType))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 80)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    private func logoDescription(for logoType: LogoType) -> String {
        switch logoType {
        case .dots:
            return "简洁的圆点设计，类似系统应用"
        case .calendar:
            return "日历风格，强调时间记录"
        case .chart:
            return "图表风格，突出数据分析"
        }
    }
}

struct LogoPreview: View {
    let logoType: LogoType
    
    var body: some View {
        Group {
            if let image = getLogoImage() {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // 备用方案：显示系统图标
                Image(systemName: "app.fill")
                    .foregroundColor(.gray)
            }
        }
        
    }
    
    #if canImport(UIKit)
    private func getLogoImage() -> UIImage? {
        let imageName: String
        switch logoType {
        case .dots:
            imageName = "AppIcon"
        case .calendar:
            imageName = "Calendar"
        case .chart:
            imageName = "Chart"
        }
        
        // 根据您的发现：使用New Image Set方式加载图片
        if let image = UIImage(named: imageName) {
            print("✅ 成功加载图片: \(imageName)")
            return image
        } else {
            print("❌ 无法加载图片: \(imageName)")
            
            // 调试：列出Bundle中的所有图片资源
            print("🔍 调试信息：")
            print("   - Bundle路径: \(Bundle.main.bundlePath)")
            if let resourcePath = Bundle.main.resourcePath {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    let imageFiles = contents.filter { $0.contains("png") || $0.contains("jpg") || $0.contains("jpeg") }
                    print("   - Bundle中的图片文件: \(imageFiles)")
                } catch {
                    print("   - 无法读取Bundle资源: \(error)")
                }
            }
        }
        
        return nil
    }
    #else
    private func getLogoImage() -> NSImage? {
        let imageName: String
        switch logoType {
        case .dots:
            imageName = "AppIcon"
        case .calendar:
            imageName = "Calendar"
        case .chart:
            imageName = "Chart"
        }
        
        // macOS 版本
        if let image = NSImage(named: imageName) {
            print("✅ 成功加载图片: \(imageName)")
            return image
        } else {
            print("❌ 无法加载图片: \(imageName)")
        }
        
        return nil
    }
    #endif
}

// MARK: - 卡片设置页面
struct CardSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var matters: [Matter]
    @State private var sortedMatters: [Matter] = []
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(sortedMatters, id: \.id) { matter in
                        HStack {
                            // 拖拽手柄
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Image(systemName: matter.icon)
                                .foregroundColor(matter.color)
                                .frame(width: 20)
                            
                            Text(matter.title)
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { matter.isEnabled },
                                set: { newValue in
                                    matter.isEnabled = newValue
                                    try? modelContext.save()
                                }
                            ))
                        }
                        .padding(.vertical, 4)
                    }
                    .onMove(perform: moveMatters)
                } header: {
                    Text("卡片列表")
                } footer: {
                    Text("长按并拖拽可调整卡片顺序，关闭卡片后，该卡片将不会在首页显示")
                }
            }
            .navigationTitle("卡片显示设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                updateSortedMatters()
            }
            .onChange(of: matters) { _, _ in
                updateSortedMatters()
            }
        }
    }
    
    private func updateSortedMatters() {
        sortedMatters = matters.sorted(by: { $0.order < $1.order })
    }
    
    private func moveMatters(from source: IndexSet, to destination: Int) {
        sortedMatters.move(fromOffsets: source, toOffset: destination)
        
        // 更新order值
        for (index, matter) in sortedMatters.enumerated() {
            matter.order = index
        }
        
        do {
            try modelContext.save()
        } catch {
            print("保存顺序失败: \(error)")
        }
    }
}

#Preview("设置页面") {
    SettingsView()
        .modelContainer(for: Matter.self, inMemory: true)
}

#Preview("卡片设置页面") {
    CardSettingsView()
        .modelContainer(for: Matter.self, inMemory: true)
}
