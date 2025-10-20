import SwiftUI
import SwiftData

struct MatterEditView: View {
    enum Mode {
        case create
        case edit(Matter)
    }
    
    enum CreationMode {
        case newList
        case template
    }
    
    let mode: Mode
    let onMatterCreated: ((Matter) -> Void)?
    let onMatterDeleted: (() -> Void)?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allMatters: [Matter]
    
    @State private var title: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColor: Color = .blue
    @State private var selectedType: MatterType = .singleSelect
    @State private var options: [MatterOption] = []
    @State private var creationMode: CreationMode = .newList
    
    @State private var showingIconPicker = false
    @State private var iconPickerId = UUID()
    @State private var showingDeleteAlert = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showingColorPicker = false
    @State private var showingOptionConfig = false
    @State private var showingValidationAlert = false
    @State private var showingDuplicateAlert = false
    @State private var showingTemplatePicker = false
    @FocusState private var isTitleFieldFocused: Bool
    @FocusState private var isAnyFieldFocused: Bool
    
    // 颜色选项（固定为十二个，参考图片两行×6样式）
    private let colorOptions: [Color] = [
        .red, .orange, .yellow, .green, .cyan, .blue,
        .indigo, .pink, .purple, .brown, .gray, .teal
    ]
    
    // 图标分类数据
    private let iconCategories: [(name: String, icons: [String])] = [
        ("情感与心情", [
            "heart.fill", "heart.circle.fill", "face.smiling.fill", "face.dashed.fill",
            "hand.thumbsup.fill", "hand.thumbsdown.fill", "star.fill", "star.circle.fill"
        ]),
        ("生活与日常", [
            "house.fill", "car.fill", "airplane", "train.side.front.car",
            "bicycle", "figure.walk", "bed.double.fill", "shower.fill"
        ]),
        ("工作与学习", [
            "briefcase.fill", "laptopcomputer", "book.fill", "pencil",
            "doc.text.fill", "folder.fill", "calendar", "clock.fill"
        ]),
        ("健康与运动", [
            "figure.run", "figure.strengthtraining.traditional", "heart.text.square.fill",
            "cross.fill", "pills.fill", "stethoscope", "bandage.fill"
        ]),
        ("娱乐与爱好", [
            "gamecontroller.fill", "music.note", "camera.fill", "paintbrush.fill",
            "theatermasks.fill", "tv.fill", "headphones", "guitars.fill"
        ]),
        ("天气与自然", [
            "sun.max.fill", "cloud.fill", "cloud.rain.fill", "snowflake",
            "leaf.fill", "tree.fill", "mountain.2.fill", "wave.3.right"
        ])
    ]
    
    // 模板数据 - 扩展更多实用模板
    private let templates: [(title: String, icon: String, color: Color, type: MatterType, options: [MatterOption], category: String)] = [
        // 情感与心情类
        (
            title: "心情",
            icon: "heart.fill",
            color: .red,
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
            category: "情感"
        ),
        (
            title: "睡眠",
            icon: "moon.stars.fill",
            color: .indigo,
            type: .singleSelect,
            options: [
                MatterOption(emoji: "😴", title: "很差"),
                MatterOption(emoji: "😪", title: "一般"),
                MatterOption(emoji: "😌", title: "还行"),
                MatterOption(emoji: "😊", title: "很好"),
                MatterOption(emoji: "✨", title: "非常好")
            ],
            category: "健康"
        ),
        // 工作与学习类
        (
            title: "工作效率",
            icon: "briefcase.fill",
            color: .blue,
            type: .singleSelect,
            options: [
                MatterOption(emoji: "😫", title: "很低"),
                MatterOption(emoji: "😐", title: "一般"),
                MatterOption(emoji: "🙂", title: "不错"),
                MatterOption(emoji: "😊", title: "很好"),
                MatterOption(emoji: "🚀", title: "高效")
            ],
            category: "工作"
        ),
        (
            title: "学习状态",
            icon: "book.fill",
            color: .green,
            type: .singleSelect,
            options: [
                MatterOption(emoji: "😵", title: "很困难"),
                MatterOption(emoji: "😐", title: "一般"),
                MatterOption(emoji: "🙂", title: "还行"),
                MatterOption(emoji: "😊", title: "很好"),
                MatterOption(emoji: "🧠", title: "很专注")
            ],
            category: "学习"
        ),
        // 健康与运动类
        (
            title: "运动强度",
            icon: "figure.run",
            color: .orange,
            type: .singleSelect,
            options: [
                MatterOption(emoji: "😴", title: "无运动"),
                MatterOption(emoji: "🚶", title: "轻度"),
                MatterOption(emoji: "🏃", title: "中度"),
                MatterOption(emoji: "💪", title: "高强度"),
                MatterOption(emoji: "🔥", title: "极限")
            ],
            category: "健康"
        ),
        (
            title: "饮食质量",
            icon: "fork.knife",
            color: .purple,
            type: .singleSelect,
            options: [
                MatterOption(emoji: "🍔", title: "不健康"),
                MatterOption(emoji: "🍕", title: "一般"),
                MatterOption(emoji: "🥗", title: "还行"),
                MatterOption(emoji: "🥙", title: "健康"),
                MatterOption(emoji: "🥑", title: "很健康")
            ],
            category: "健康"
        ),
        // 生活日常类
        (
            title: "天气",
            icon: "sun.max.fill",
            color: .yellow,
            type: .singleSelect,
            options: [
                MatterOption(emoji: "☀️", title: "晴天"),
                MatterOption(emoji: "⛅", title: "多云"),
                MatterOption(emoji: "☁️", title: "阴天"),
                MatterOption(emoji: "🌧️", title: "雨天"),
                MatterOption(emoji: "❄️", title: "雪天")
            ],
            category: "生活"
        ),
        (
            title: "社交活动",
            icon: "person.2.fill",
            color: .pink,
            type: .singleSelect,
            options: [
                MatterOption(emoji: "😔", title: "独处"),
                MatterOption(emoji: "😐", title: "少量"),
                MatterOption(emoji: "🙂", title: "适中"),
                MatterOption(emoji: "😊", title: "丰富"),
                MatterOption(emoji: "🎉", title: "很活跃")
            ],
            category: "生活"
        )
    ]
    
    var navigationTitle: String {
        switch mode {
        case .create: return "新建事项"
        case .edit: return "编辑事项"
        }
    }
    
    private var isFormValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasTitle = !trimmedTitle.isEmpty
        let hasOptions = !options.isEmpty
        let isTitleUnique = isTitleUnique(trimmedTitle)
        
        // 单选和多选类型必须有选项
        if selectedType == .singleSelect || selectedType == .multiSelect {
            return hasTitle && hasOptions && isTitleUnique
        }
        
        // 其他类型只需要标题且不重复
        return hasTitle && isTitleUnique
    }
    
    // 检查标题是否唯一
    private func isTitleUnique(_ title: String) -> Bool {
        switch mode {
        case .create:
            // 创建模式下，检查是否与任何现有事项重复
            return !allMatters.contains { $0.title.lowercased() == title.lowercased() }
        case .edit(let currentMatter):
            // 编辑模式下，检查是否与其他事项重复（排除当前事项）
            return !allMatters.contains { 
                $0.id != currentMatter.id && $0.title.lowercased() == title.lowercased() 
            }
        }
    }

    // 独立子视图：颜色网格（圆角背景）
    private var colorGridSection: some View {
        VStack {
            colorGrid
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var colorGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(colorOptions, id: \.self) { color in
                colorButton(color: color)
            }
        }
        .padding(12)
    }
    
    private func colorButton(color: Color) -> some View {
        Button(action: { selectedColor = color }) {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    Group {
                        if selectedColor == color {
                            Circle().stroke(Color.white, lineWidth: 2)
                        }
                    }
                )
                .overlay(
                    Group {
                        if selectedColor == color {
                            Circle().stroke(Color.gray.opacity(0.3), lineWidth: 3)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }

    // 独立子视图：图标网格（圆角背景）
    private var iconGridSection: some View {
        VStack(spacing: 0) {
            iconGrid
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var iconGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(iconCategories.flatMap { $0.icons }, id: \.self) { icon in
                iconButton(icon: icon)
            }
        }
        .padding(12)
    }
    
    private func iconButton(icon: String) -> some View {
        Button(action: { selectedIcon = icon }) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.primary)
                .frame(width: 48, height: 48)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: selectedIcon == icon ? 2 : 0)
                )
        }
        .buttonStyle(.plain)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 分段控制器（仅在创建模式下显示）
                    if case .create = mode {
                        Picker("创建模式", selection: $creationMode) {
                            Text("新建列表").tag(CreationMode.newList)
                            Text("模板").tag(CreationMode.template)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    // 根据模式显示不同内容
                    if case .create = mode, creationMode == .template {
                        // 模板选择模式
                        templateSelectionView
                    } else {
                        // 新建列表模式
                        newListCreationView
                    }
                }
                .padding(.horizontal)
            }
            .offset(y: scrollOffset)
            .navigationTitle(navigationTitle)
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button("取消") { dismiss() }
                        if case .edit = mode {
                            Button("删除") { showingDeleteAlert = true }
                                .foregroundColor(.red)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") { save() }
                        .disabled(!isFormValid)
                        .fontWeight(.semibold)
                }
            }
            .alert("删除事项", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) { deleteMatter() }
            } message: { Text("确定要删除这个事项吗？此操作无法撤销。") }
            .alert("无法保存", isPresented: $showingValidationAlert) {
                Button("好的") { }
            } message: { 
                let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                let hasTitle = !trimmed.isEmpty
                let hasOptions = !options.isEmpty
                
                if !hasTitle {
                    return Text("请输入事项名称")
                } else if (selectedType == .singleSelect || selectedType == .multiSelect) && !hasOptions {
                    return Text("请至少添加一个选项")
                } else {
                    return Text("请检查输入内容")
                }
            }
            .alert("标题重复", isPresented: $showingDuplicateAlert) {
                Button("好的") { }
            } message: { 
                Text("该标题已存在，请使用不同的标题")
            }
            .onAppear { 
                load()
                // 创建模式下自动聚焦到标题输入框
                if case .create = mode {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isTitleFieldFocused = true
                    }
                }
            }
            .onTapGesture {
                // 点击空白区域收起键盘
                isAnyFieldFocused = false
            }
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        // 滑动时收起键盘
                        isAnyFieldFocused = false
                    }
            )
            .sheet(isPresented: $showingIconPicker) {
                MatterIconPickerView(selectedIcon: $selectedIcon, selectedColor: selectedColor, iconCategories: iconCategories)
                    .id(iconPickerId)
            }
            .sheet(isPresented: $showingOptionConfig) {
                OptionConfigView(
                    options: $options,
                    onComplete: {
                        showingOptionConfig = false
                    }
                )
            }
        }
        .sheet(isPresented: $showingColorPicker) {
            NavigationView {
                VStack {
                    ColorPicker("选择主题色", selection: $selectedColor, supportsOpacity: false)
                        .padding()
                    Spacer()
                }
                .navigationTitle("选择颜色")
                #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .secondaryAction) {
                        Button("完成") { showingColorPicker = false }
                    }
                }
            }
        }
    }
    
    // 新建列表创建视图
    private var newListCreationView: some View {
        VStack(spacing: 20) {
            // 图标和标题区域
            VStack(spacing: 16) {
                // 大图标显示
                Button(action: { 
                    iconPickerId = UUID()
                    showingIconPicker = true 
                }) {
                    Image(systemName: selectedIcon)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(selectedColor)
                        .cornerRadius(20)
                        .shadow(color: selectedColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                
                // 标题输入框
                VStack(spacing: 8) {
                    TextField("事项名称", text: $title)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .frame(maxWidth: 260)
                        .focused($isTitleFieldFocused)
                        .focused($isAnyFieldFocused)
                    
                    // 重复标题警告提示
                    if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isTitleUnique(title.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("该标题已存在")
                                .font(.caption)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            .padding(.top, 20)
            
            // 类型选择（行内弹出菜单样式）
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("事项类型")
                    .font(.body)
                Spacer()
                Menu {
                    Button(action: {
                        selectedType = .singleSelect
                    }) {
                        HStack {
                            Text(MatterType.singleSelect.displayName)
                            Spacer()
                            if selectedType == .singleSelect {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    
                    Button(action: {
                        selectedType = .multiSelect
                    }) {
                        HStack {
                            Text(MatterType.multiSelect.displayName)
                            Spacer()
                            if selectedType == .multiSelect {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(selectedType.displayName)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .menuStyle(.automatic)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            // 选项配置按钮（紧随类型下方）
            if selectedType == .singleSelect || selectedType == .multiSelect {
                VStack(spacing: 8) {
                    HStack {
                        Button(action: { showingOptionConfig = true }) {
                            HStack {
                                Image(systemName: "list.bullet.clipboard")
                                    .foregroundColor(.blue)
                                Text("配置选项 (\(options.count)个)")
                                    .font(.body)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    
                        // 快速查看已有选项的按钮
                        if !options.isEmpty {
                            Menu {
                                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                                    Button(action: {}) {
                                        Text(option.title)
                                            .font(.body)
                                    }
                                }
                            } label: {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                    .frame(width: 32, height: 32)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // 警告提示：当没有选项时显示
                    if options.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("请至少添加一个选项才能保存")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            
            colorGridSection
            iconGridSection
            
            Spacer(minLength: 100) // 底部留白
        }
    }
    
    // 模板选择视图
    private var templateSelectionView: some View {
        VStack(spacing: 20) {
            // 模板分类
            let categories = Array(Set(templates.map { $0.category })).sorted()
            
            ForEach(categories, id: \.self) { category in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: categoryIcon(for: category))
                            .foregroundColor(.blue)
                            .font(.title3)
                        Text(category)
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(templates.filter { $0.category == category }, id: \.title) { template in
                            Button(action: {
                                applyTemplate(template)
                                creationMode = .newList
                            }) {
                                VStack(spacing: 8) {
                                    // 模板图标
                                    Image(systemName: template.icon)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                        .background(template.color)
                                        .cornerRadius(12)
                                    
                                    // 模板标题
                                    Text(template.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    
                                    // 选项预览
                                    HStack(spacing: 2) {
                                        ForEach(template.options.prefix(3), id: \.title) { option in
                                            Text(option.emoji)
                                                .font(.caption)
                                        }
                                        if template.options.count > 3 {
                                            Text("+\(template.options.count - 3)")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            
            Spacer(minLength: 100)
        }
    }
    
    // 获取分类图标
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "情感": return "heart.fill"
        case "健康": return "heart.text.square.fill"
        case "工作": return "briefcase.fill"
        case "学习": return "book.fill"
        case "生活": return "house.fill"
        default: return "star.fill"
        }
    }
    
    // 应用模板
    private func applyTemplate(_ template: (title: String, icon: String, color: Color, type: MatterType, options: [MatterOption], category: String)) {
        title = template.title
        selectedIcon = template.icon
        selectedColor = template.color
        selectedType = template.type
        options = template.options
    }
    
    private func load() {
        switch mode {
        case .create:
            break
        case .edit(let matter):
            title = matter.title
            selectedIcon = matter.icon
            selectedColor = matter.color
            selectedType = matter.type
            options = matter.options
        }
    }
    
    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasTitle = !trimmed.isEmpty
        let hasOptions = !options.isEmpty
        let isTitleUnique = isTitleUnique(trimmed)
        
        // 验证标题
        guard hasTitle else { 
            showingValidationAlert = true
            return 
        }
        
        // 验证标题唯一性
        guard isTitleUnique else {
            showingDuplicateAlert = true
            return
        }
        
        // 验证选项（单选和多选类型必须有选项）
        if (selectedType == .singleSelect || selectedType == .multiSelect) && !hasOptions {
            showingValidationAlert = true
            return
        }
        
        switch mode {
        case .create:
            let m = Matter(
                title: trimmed,
                icon: selectedIcon,
                type: selectedType,
                options: options,
                accentColorHex: selectedColor.toHex()
            )
            modelContext.insert(m)
            do { 
                try modelContext.save()
                onMatterCreated?(m)
                dismiss() 
            } catch { print("保存事项失败: \(error)") }
        case .edit(let matter):
            matter.title = trimmed
            matter.icon = selectedIcon
            matter.type = selectedType
            matter.options = options
            matter.accentColorHex = selectedColor.toHex()
            do { try modelContext.save(); dismiss() } catch { print("保存事项失败: \(error)") }
        }
    }
    
    private func deleteMatter() {
        if case .edit(let matter) = mode {
            modelContext.delete(matter)
            do { 
                try modelContext.save()
                onMatterDeleted?()
                dismiss() 
            } catch { print("删除事项失败: \(error)") }
        }
    }
}

private struct MatterIconPickerView: View {
    @Binding var selectedIcon: String
    let selectedColor: Color
    let iconCategories: [(name: String, icons: [String])]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(iconCategories, id: \.name) { category in
                    Section(category.name) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(category.icons, id: \.self) { icon in
                                Button(action: {
                                    selectedIcon = icon
                                    dismiss()
                                }) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                        .frame(width: 44, height: 44)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("选择图标")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

private struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss
    
    private let emojiPalette = [
        "😊","😄","😀","🙂","😌","✨","🔆","💪","🏆","🎯",
        "😐","🧘","🧊","🎯","🧠","📚","🗒️","🕰️","🧩","📎",
        "😟","😬","😣","😔","😢","🥱","😡","😱","😓","🌫️",
        "💡","🍃","🌙","🌃","☀️","🕛","🏃","🥗","🍻","🤒"
    ]
    
    var body: some View {
        NavigationView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                ForEach(emojiPalette, id: \.self) { emoji in
                    Button(action: {
                        selectedEmoji = emoji
                        dismiss()
                    }) {
                        Text(emoji)
                            .font(.title)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("选择表情")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}