import SwiftUI
import SwiftData

// 通用模块内容组件（用于CardContainer内部）
// 旧 GenericModuleContent 已移除

// 通用事项内容组件（用于CardContainer内部）
struct GenericMatterContent: View {
    let matter: Matter
    @State private var selectedOptions: Set<UUID> = []
    @State private var singleSelectionId: UUID? = nil
    @State private var textInput: String = ""
    @State private var numberInput: Double = 0
    @State private var selectedDate: Date = Date()
    
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [MatterRecord]
    
    private var todayRecord: MatterRecord? {
        let todayRecords = records.filter { $0.matterId == matter.id && Calendar.current.isDateInToday($0.date) }
        // 如果同一天有多条记录，返回最新创建的
        return todayRecords.max(by: { $0.createdAt < $1.createdAt })
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                contentView
            }
        }
        .onAppear { loadTodayRecord() }
        .onChange(of: selectedOptions) { _, _ in saveRecord() }
        .onChange(of: singleSelectionId) { _, _ in saveRecord() }
        .onChange(of: textInput) { _, _ in saveRecord() }
        .onChange(of: numberInput) { _, _ in saveRecord() }
        .onChange(of: selectedDate) { _, _ in saveRecord() }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch matter.type {
        case .singleSelect:
            singleSelectView
        case .multiSelect:
            multiSelectView
        }
    }
    
    private var singleSelectView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择一个选项")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            optionsListView
        }
    }
    
    private var optionsListView: some View {
        VStack(spacing: 8) {
            ForEach(matter.options) { opt in
                optionRow(opt: opt)
            }
        }
    }
    
    private func optionRow(opt: MatterOption) -> some View {
        HStack {
            radioButton(isSelected: singleSelectionId == opt.id)
            Text(opt.displayText)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(singleSelectionId == opt.id ? matter.color.opacity(0.1) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(singleSelectionId == opt.id ? matter.color.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
        .onTapGesture { singleSelectionId = opt.id }
    }
    
    private func radioButton(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(matter.color, lineWidth: 2)
                .frame(width: 20, height: 20)
                .background(
                    Circle()
                        .fill(isSelected ? matter.color : Color.clear)
                )
            
            if isSelected {
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    private var multiSelectView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择多个选项")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                ForEach(matter.options) { opt in
                    HStack {
                        // 复选框样式
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(matter.color, lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(selectedOptions.contains(opt.id) ? matter.color : Color.clear)
                                )
                            
                            if selectedOptions.contains(opt.id) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(opt.displayText)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedOptions.contains(opt.id) ? matter.color.opacity(0.1) : Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedOptions.contains(opt.id) ? matter.color.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    )
                    .onTapGesture { toggle(opt.id) }
                }
            }
        }
    }
    
    private var dateSelectView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择日期")
                .font(.subheadline)
                .foregroundColor(.secondary)
            DatePicker("日期", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(matter.color)
        }
    }
    
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("输入文本")
                .font(.subheadline)
                .foregroundColor(.secondary)
            ZStack(alignment: .topLeading) {
                if textInput.isEmpty {
                    Text("输入内容...")
                        .foregroundColor(.secondary)
                        .padding(.top, 6)
                        .padding(.leading, 4)
                }
                TextEditor(text: $textInput)
                    .font(.body)
                    .frame(minHeight: 100, maxHeight: 200)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
        }
    }
    
    private var numberInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("输入数字")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                TextField("0", value: $numberInput, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if canImport(UIKit)
                    .keyboardType(.decimalPad)
                    #endif
                Stepper("", value: $numberInput, in: 0...1000, step: 1)
                    .labelsHidden()
            }
        }
    }
    
    private func toggle(_ id: UUID) {
        if selectedOptions.contains(id) {
            selectedOptions.remove(id)
        } else {
            selectedOptions.insert(id)
        }
    }
    
    private func loadTodayRecord() {
        guard let record = todayRecord else { return }
        switch matter.type {
        case .singleSelect:
            singleSelectionId = record.singleOptionId
        case .multiSelect:
            selectedOptions = Set(record.selectedOptionIds)
        }
    }
    
    private func saveRecord() {
        let record: MatterRecord
        if let existing = todayRecord { record = existing } else {
            record = MatterRecord(matterId: matter.id)
            modelContext.insert(record)
        }
        switch matter.type {
        case .singleSelect:
            record.singleOptionId = singleSelectionId
        case .multiSelect:
            record.selectedOptionIds = Array(selectedOptions)
        }
        do { try modelContext.save() } catch { print("保存事项记录失败: \(error)") }
    }
}

// 通用模块卡片组件（完整卡片，包含头部和内容）
struct GenericModuleCard: View {
    let module: CustomModule
    @State private var selectedOptions: Set<String> = []
    @State private var singleSelection: String = ""
    @State private var textInput: String = ""
    @State private var numberInput: Double = 0
    @State private var selectedDate: Date = Date()
    
    @Environment(\.modelContext) private var modelContext
    @Query private var moduleRecords: [ModuleRecord]
    
    private var todayRecord: ModuleRecord? {
        moduleRecords.first { record in
            record.moduleId == module.id && Calendar.current.isDateInToday(record.date)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            contentArea
        }
        .frame(height: 420)
        .onAppear {
            loadTodayRecord()
        }
        .onChange(of: selectedOptions) { _, _ in saveRecord() }
        .onChange(of: singleSelection) { _, _ in saveRecord() }
        .onChange(of: textInput) { _, _ in saveRecord() }
        .onChange(of: numberInput) { _, _ in saveRecord() }
        .onChange(of: selectedDate) { _, _ in saveRecord() }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: module.icon)
                .font(.body)
                .foregroundColor(.white)
            Text(module.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Spacer()
            
            Button(action: { 
                // 这里可以添加编辑功能，暂时使用清除功能
                clearSelection() 
            }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Button(action: { clearSelection() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(
            LinearGradient(gradient: Gradient(colors: [module.color.opacity(0.8), module.color]), 
                          startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
    }
    
    private var contentArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            contentView
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch module.moduleType {
        case .singleSelect:
            singleSelectView
        case .multiSelect:
            multiSelectView
        }
    }
    
    // 单选视图
    private var singleSelectView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择一个选项")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                ForEach(module.options, id: \.self) { option in
                    HStack {
                        // 单选按钮样式
                        ZStack {
                            Circle()
                                .stroke(module.color, lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .background(
                                    Circle()
                                        .fill(singleSelection == option ? module.color : Color.clear)
                                )
                            
                            if singleSelection == option {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Text(option)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(singleSelection == option ? module.color.opacity(0.1) : Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(singleSelection == option ? module.color.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    )
                    .onTapGesture {
                        singleSelection = option
                    }
                }
            }
        }
    }
    
    // 多选视图
    private var multiSelectView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择多个选项")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                ForEach(module.options, id: \.self) { option in
                    HStack {
                        // 复选框样式
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(module.color, lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(selectedOptions.contains(option) ? module.color : Color.clear)
                                )
                            
                            if selectedOptions.contains(option) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(option)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedOptions.contains(option) ? module.color.opacity(0.1) : Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedOptions.contains(option) ? module.color.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    )
                    .onTapGesture { toggleSelection(option) }
                }
            }
        }
    }
    
    // 日期选择视图
    private var dateSelectView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择日期")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            DatePicker("日期", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(module.color)
        }
    }
    
    // 文本输入视图
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("输入文本")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .topLeading) {
                if textInput.isEmpty {
                    Text("输入内容...")
                        .foregroundColor(.secondary)
                        .padding(.top, 6)
                        .padding(.leading, 4)
                }
                TextEditor(text: $textInput)
                    .font(.body)
                    .frame(minHeight: 100, maxHeight: 200)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
        }
    }
    
    // 数字输入视图
    private var numberInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("输入数字")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("0", value: $numberInput, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if canImport(UIKit)
                    .keyboardType(.decimalPad)
                    #endif
                
                Stepper("", value: $numberInput, in: 0...1000, step: 1)
                    .labelsHidden()
            }
        }
    }
    
    // 切换选择状态
    private func toggleSelection(_ option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
    
    // 清除选择
    private func clearSelection() {
        selectedOptions.removeAll()
        singleSelection = ""
        textInput = ""
        numberInput = 0
        selectedDate = Date()
        saveRecord()
    }
    
    // 加载今日记录
    private func loadTodayRecord() {
        guard let record = todayRecord else { return }
        
        switch module.moduleType {
        case .singleSelect:
            singleSelection = record.singleOption ?? ""
        case .multiSelect:
            selectedOptions = Set(record.selectedOptions)
        }
    }
    
    // 保存记录
    private func saveRecord() {
        let record: ModuleRecord
        
        if let existingRecord = todayRecord {
            record = existingRecord
        } else {
            record = ModuleRecord(moduleId: module.id)
            modelContext.insert(record)
        }
        
        // 更新记录数据
        switch module.moduleType {
        case .singleSelect:
            record.singleOption = singleSelection.isEmpty ? nil : singleSelection
        case .multiSelect:
            record.selectedOptions = Array(selectedOptions)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("保存记录失败: \(error)")
        }
    }
}

// 旧“模块管理”界面已移除
