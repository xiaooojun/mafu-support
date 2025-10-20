//
//  DailyHistoryView.swift
//  Life
//
//  Created by tangxj on 10/13/25.
//

import SwiftUI
import SwiftData
import Charts
#if canImport(UIKit)
import UIKit // For UIPasteboard
#endif

enum TimeRange: String, CaseIterable {
    case week = "最近一周"
    case month = "最近一月"
    case all = "全部"
}

enum ChartViewMode: String, CaseIterable {
    case week = "周视图"
    case month = "月视图"
}


struct DailyHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MatterRecord.date, order: .reverse) private var matterRecords: [MatterRecord]
    @Query(sort: \Matter.order) private var matters: [Matter]
    
    private let appBackground = Color.gray.opacity(0.1)
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMatter: Matter? = nil
    @State private var chartViewMode: ChartViewMode = .week
    @State private var showingRecordDetail = false
    @State private var selectedRecordDate: Date? = nil
    
    // 根据选择的时间范围过滤记录
    private var filteredRecords: [MatterRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        let baseRecords: [MatterRecord]
        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            baseRecords = matterRecords.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            baseRecords = matterRecords.filter { $0.date >= monthAgo }
        case .all:
            baseRecords = matterRecords
        }
        
        // 去重：同一天只保留最新的一条记录
        return removeDuplicateRecords(baseRecords)
    }
    
    // 去重同一天的记录，保留最新的
    private func removeDuplicateRecords(_ records: [MatterRecord]) -> [MatterRecord] {
        let calendar = Calendar.current
        var dateToRecordMap: [String: MatterRecord] = [:]
        
        for record in records {
            let dateKey = calendar.dateInterval(of: .day, for: record.date)?.start.timeIntervalSince1970.description ?? ""
            
            if let existingRecord = dateToRecordMap[dateKey] {
                // 如果已存在同一天的记录，保留创建时间更新的
                if record.createdAt > existingRecord.createdAt {
                    dateToRecordMap[dateKey] = record
                }
            } else {
                dateToRecordMap[dateKey] = record
            }
        }
        
        return Array(dateToRecordMap.values)
    }
    
    // 事项统计图表数据
    private var chartData: [ChartDataPoint] {
        guard let selectedMatter = selectedMatter else { return [] }
        
        let matterRecords = filteredRecords.filter { $0.matterId == selectedMatter.id }
        let groupedRecords = Dictionary(grouping: matterRecords) { record in
            Calendar.current.startOfDay(for: record.date)
        }
        
        return groupedRecords.compactMap { (date, records) in
            if let record = records.first {
                let optionLabel = getOptionLabel(from: record, matter: selectedMatter)
                let value = getOptionValue(from: record, matter: selectedMatter)
                return ChartDataPoint(date: date, value: value, label: optionLabel)
            }
            return nil
        }.sorted { $0.date < $1.date }
    }
    
    // 根据视图模式获取图表数据
    private var displayChartData: [ChartDataPoint] {
        let baseData = chartData
        guard !baseData.isEmpty else { return [] }
        
        switch chartViewMode {
        case .week:
            return getWeeklyData(from: baseData)
        case .month:
            return getMonthlyData(from: baseData)
        }
    }
    
    // 获取周视图数据（按周分组，显示每周最常选择的选项）
    private func getWeeklyData(from data: [ChartDataPoint]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let groupedByWeek = Dictionary(grouping: data) { dataPoint in
            calendar.dateInterval(of: .weekOfYear, for: dataPoint.date)?.start ?? dataPoint.date
        }
        
        return groupedByWeek.compactMap { (weekStart, weekData) in
            guard !weekData.isEmpty else { return nil }
            // 找到本周最常选择的选项
            let mostCommonLabel = getMostCommonLabel(from: weekData)
            // 找到对应的数值
            let mostCommonValue = weekData.first { $0.label == mostCommonLabel }?.value ?? 0
            return ChartDataPoint(date: weekStart, value: mostCommonValue, label: mostCommonLabel)
        }.sorted { $0.date < $1.date }
    }
    
    // 获取月视图数据（按月分组，显示每月最常选择的选项）
    private func getMonthlyData(from data: [ChartDataPoint]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let groupedByMonth = Dictionary(grouping: data) { dataPoint in
            calendar.dateInterval(of: .month, for: dataPoint.date)?.start ?? dataPoint.date
        }
        
        return groupedByMonth.compactMap { (monthStart, monthData) in
            guard !monthData.isEmpty else { return nil }
            // 找到本月最常选择的选项
            let mostCommonLabel = getMostCommonLabel(from: monthData)
            // 找到对应的数值
            let mostCommonValue = monthData.first { $0.label == mostCommonLabel }?.value ?? 0
            return ChartDataPoint(date: monthStart, value: mostCommonValue, label: mostCommonLabel)
        }.sorted { $0.date < $1.date }
    }
    
    // 获取最常出现的标签
    private func getMostCommonLabel(from data: [ChartDataPoint]) -> String {
        let labelCounts = Dictionary(grouping: data, by: { $0.label })
        return labelCounts.max(by: { $0.value.count < $1.value.count })?.key ?? "未知"
    }
    
    
    // 从MatterRecord中获取选项标题
    private func getOptionTitle(from record: MatterRecord, matter: Matter) -> String {
        if let singleOptionId = record.singleOptionId,
           let option = matter.options.first(where: { $0.id == singleOptionId }) {
            return option.title
        } else if !record.selectedOptionIds.isEmpty {
            let selectedOptions = matter.options.filter { option in
                record.selectedOptionIds.contains(option.id)
            }
            return selectedOptions.map { $0.title }.joined(separator: ", ")
        }
        
        return "未选择"
    }
    
    // 从MatterRecord中获取选项数值（用于图表显示）
    private func getOptionValue(from record: MatterRecord, matter: Matter) -> Double {
        if let singleOptionId = record.singleOptionId,
           let option = matter.options.first(where: { $0.id == singleOptionId }) {
            // 对于单选，返回选项在列表中的索引位置
            if let index = matter.options.firstIndex(where: { $0.id == option.id }) {
                return Double(index + 1)
            }
        } else if !record.selectedOptionIds.isEmpty {
            // 对于多选，返回选中选项的数量
            return Double(record.selectedOptionIds.count)
        }
        
        return 0.0
    }
    
    // 从MatterRecord中获取选项标签（用于图表显示）
    private func getOptionLabel(from record: MatterRecord, matter: Matter) -> String {
        if let singleOptionId = record.singleOptionId,
           let option = matter.options.first(where: { $0.id == singleOptionId }) {
            return option.title
        } else if !record.selectedOptionIds.isEmpty {
            let selectedOptions = matter.options.filter { option in
                record.selectedOptionIds.contains(option.id)
            }
            return selectedOptions.map { $0.title }.joined(separator: ", ")
        }
        
        return "未选择"
    }
    
    // MARK: - 空状态
    private var emptyState: some View {
        ContentUnavailableView("暂无记录", systemImage: "tray.fill", description: Text("开始记录你的生活吧！"))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    // MARK: - 时间范围选择器
                    Picker("时间范围", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    // MARK: - 统计概览卡片
                    if !filteredRecords.isEmpty {
                        statisticsCardsSection
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                    
                    // MARK: - 趋势图表
                    if !filteredRecords.isEmpty {
                        VStack(spacing: 20) {
                            // 周月视图选择器
                            Picker("视图模式", selection: $chartViewMode) {
                                ForEach(ChartViewMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            
                            // 事项选择器
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(matters, id: \.id) { matter in
                                        MatterSelectionCard(
                                            matter: matter,
                                            isSelected: selectedMatter?.id == matter.id
                                        ) {
                                            selectedMatter = matter
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // 趋势图表显示
                            if let selectedMatter = selectedMatter {
                                TrendChartView(
                                    data: displayChartData,
                                    matter: selectedMatter,
                                    viewMode: chartViewMode
                                )
                                .frame(height: 250)
                            } else {
                                VStack {
                                    Text("请选择一个事项查看趋势")
                                        .foregroundColor(.secondary)
                                        .font(.headline)
                                    Text("选择上方的事项卡片开始查看数据趋势")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                }
                                .frame(height: 250)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    } else {
                        emptyState
                    }
                }
                .padding(.bottom, 20)
            }
            .background(appBackground)
            // iOS 26 优化：更精细的导航栏背景控制
            .toolbarBackground(appBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle("数据统计")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // iOS 26 优化：更精细的导航栏外观控制
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(appBackground)
                appearance.shadowColor = .clear
                
                // iOS 26 新特性：支持动态岛设备的导航栏适配
                appearance.titleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                    .foregroundColor: UIColor.label
                ]
                appearance.largeTitleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 34, weight: .bold),
                    .foregroundColor: UIColor.label
                ]
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
                
                // iOS 26 优化：支持动态岛设备的顶部安全区域
                UINavigationBar.appearance().prefersLargeTitles = true
                UINavigationBar.appearance().isTranslucent = false
                UINavigationBar.appearance().barTintColor = UIColor(appBackground)
            }
        }
        .background(appBackground)
        .sheet(isPresented: $showingRecordDetail) {
            RecordDetailView(
                records: filteredRecords,
                matters: matters,
                onRecordTap: { date in
                    selectedRecordDate = date
                }
            )
        }
        .sheet(isPresented: Binding<Bool>(
            get: { selectedRecordDate != nil },
            set: { if !$0 { selectedRecordDate = nil } }
        )) {
            if let date = selectedRecordDate {
                RecordEditView(date: date, matters: matters)
            }
        }
    }
    
    // MARK: - 统计卡片组
    private var statisticsCardsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // 记录天数卡片
                StatisticsCard(
                    title: "记录天数",
                    value: "\(filteredRecords.count)",
                    trend: getRecordTrend(),
                    color: .green,
                    icon: "calendar",
                    onTap: { showingRecordDetail = true }
                )
                
                // 事项数量卡片
                StatisticsCard(
                    title: "事项数量",
                    value: "\(matters.count)",
                    trend: getMatterTrend(),
                    color: .blue,
                    icon: "list.bullet",
                    onTap: { showingRecordDetail = true }
                )
                
                // 完成率卡片
                StatisticsCard(
                    title: "完成率",
                    value: "\(getCompletionRate())%",
                    trend: getCompletionTrend(),
                    color: .orange,
                    icon: "checkmark.circle",
                    onTap: { showingRecordDetail = true }
                )
                
                // 连续天数卡片
                StatisticsCard(
                    title: "连续天数",
                    value: "\(getConsecutiveDays())",
                    trend: getConsecutiveTrend(),
                    color: .purple,
                    icon: "flame",
                    onTap: { showingRecordDetail = true }
                )
            }
            .padding(.horizontal, 4)
        }
    }
    
    // MARK: - 统计数据计算
    private func getRecordTrend() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // 计算本周记录数
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let thisWeekRecords = filteredRecords.filter { $0.date >= weekStart }.count
        
        // 计算上周记录数
        let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: weekStart) ?? now
        let lastWeekEnd = calendar.date(byAdding: .day, value: 6, to: lastWeekStart) ?? now
        let lastWeekRecords = matterRecords.filter { 
            $0.date >= lastWeekStart && $0.date <= lastWeekEnd 
        }.count
        
        if lastWeekRecords == 0 {
            return thisWeekRecords > 0 ? "↗️ 新增" : "➡️ 持平"
        }
        
        let change = thisWeekRecords - lastWeekRecords
        if change > 0 {
            return "↗️ +\(change)"
        } else if change < 0 {
            return "↘️ \(change)"
        } else {
            return "➡️ 持平"
        }
    }
    
    private func getMatterTrend() -> String {
        let enabledMatters = matters.filter { $0.isEnabled }.count
        let totalMatters = matters.count
        
        if totalMatters == 0 {
            return "➡️ 无"
        }
        
        let enabledRate = Double(enabledMatters) / Double(totalMatters) * 100
        if enabledRate >= 80 {
            return "↗️ 活跃"
        } else if enabledRate >= 50 {
            return "➡️ 正常"
        } else {
            return "↘️ 较少"
        }
    }
    
    private func getCompletionRate() -> Int {
        guard !matters.isEmpty else { return 0 }
        
        let totalPossibleRecords = matters.count * 7 // 假设一周7天
        let actualRecords = filteredRecords.count
        
        return min(100, Int(Double(actualRecords) / Double(totalPossibleRecords) * 100))
    }
    
    private func getCompletionTrend() -> String {
        let rate = getCompletionRate()
        if rate >= 80 {
            return "↗️ 优秀"
        } else if rate >= 60 {
            return "➡️ 良好"
        } else if rate >= 40 {
            return "↘️ 一般"
        } else {
            return "↘️ 需努力"
        }
    }
    
    private func getConsecutiveDays() -> Int {
        let calendar = Calendar.current
        let sortedDates = filteredRecords.map { $0.date }.sorted(by: >)
        
        var consecutiveDays = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for date in sortedDates {
            let recordDate = calendar.startOfDay(for: date)
            if calendar.isDate(recordDate, inSameDayAs: currentDate) {
                consecutiveDays += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return consecutiveDays
    }
    
    private func getConsecutiveTrend() -> String {
        let days = getConsecutiveDays()
        if days >= 7 {
            return "↗️ 坚持"
        } else if days >= 3 {
            return "➡️ 稳定"
        } else if days > 0 {
            return "↘️ 开始"
        } else {
            return "↘️ 中断"
        }
    }
}

// MARK: - 统计卡片组件
struct StatisticsCard: View {
    let title: String
    let value: String
    let trend: String
    let color: Color
    let icon: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // 标题和趋势
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.subheadline)
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(trend)
                        .font(.caption)
                        .foregroundColor(trendColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(trendBackgroundColor)
                        .cornerRadius(8)
                }
                
                // 数值
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .frame(width: 140)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var trendColor: Color {
        if trend.contains("↗️") {
            return .green
        } else if trend.contains("↘️") {
            return .red
        } else {
            return .secondary
        }
    }
    
    private var trendBackgroundColor: Color {
        if trend.contains("↗️") {
            return .green.opacity(0.1)
        } else if trend.contains("↘️") {
            return .red.opacity(0.1)
        } else {
            return .secondary.opacity(0.1)
        }
    }
}

// MARK: - 记录详情页面
struct RecordDetailView: View {
    let records: [MatterRecord]
    let matters: [Matter]
    let onRecordTap: (Date) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var groupedRecords: [(Date, [MatterRecord])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedRecords, id: \.0) { date, dayRecords in
                    Section(header: Text(formatDate(date))) {
                        ForEach(dayRecords, id: \.id) { record in
                            RecordRowView(
                                record: record,
                                matter: matters.first { $0.id == record.matterId },
                                onTap: {
                                    onRecordTap(record.date)
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("记录详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - 记录行视图
struct RecordRowView: View {
    let record: MatterRecord
    let matter: Matter?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // 事项图标
                if let matter = matter {
                    Image(systemName: matter.icon)
                        .foregroundColor(matter.color)
                        .frame(width: 24, height: 24)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // 事项名称
                    Text(matter?.title ?? "未知事项")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // 选择的内容
                    let selectedText = getSelectedText(for: record, matter: matter)
                    Text(selectedText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // 时间
                Text(formatTime(record.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 编辑图标
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func getSelectedText(for record: MatterRecord, matter: Matter?) -> String {
        guard let matter = matter else { return "无选择" }
        
        if matter.type == .singleSelect {
            if let singleOptionId = record.singleOptionId,
               let option = matter.options.first(where: { $0.id == singleOptionId }) {
                return option.displayText
            }
        } else if matter.type == .multiSelect {
            let selectedOptions = matter.options.filter { option in
                record.selectedOptionIds.contains(option.id)
            }
            if !selectedOptions.isEmpty {
                return selectedOptions.map { $0.displayText }.joined(separator: ", ")
            }
        }
        
        return "无选择"
    }
}

// MARK: - 记录编辑页面
struct RecordEditView: View {
    let date: Date
    let matters: [Matter]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedItems: [String: [String]] = [:]
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 日期标题
                    Text(formatDate(date))
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // 事项选择
                    ForEach(matters.filter { $0.isEnabled }, id: \.id) { matter in
                        MatterEditCard(
                            matter: matter,
                            selectedItems: Binding(
                                get: { selectedItems[matter.id.uuidString] ?? [] },
                                set: { selectedItems[matter.id.uuidString] = $0 }
                            )
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("编辑记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveRecord()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadExistingRecord()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func loadExistingRecord() {
        // 查找当天的记录
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        let existingRecords = try? modelContext.fetch(
            FetchDescriptor<MatterRecord>(
                predicate: #Predicate { record in
                    record.date >= startOfDay && record.date < endOfDay
                }
            )
        )
        
        // 加载现有选择
        for record in existingRecords ?? [] {
            let matterIdString = record.matterId.uuidString
            var items: [String] = []
            
            if let matter = matters.first(where: { $0.id == record.matterId }) {
                if matter.type == .singleSelect {
                    if let singleOptionId = record.singleOptionId,
                       let option = matter.options.first(where: { $0.id == singleOptionId }) {
                        items = [option.displayText]
                    }
                } else if matter.type == .multiSelect {
                    let selectedOptions = matter.options.filter { option in
                        record.selectedOptionIds.contains(option.id)
                    }
                    items = selectedOptions.map { $0.displayText }
                }
            }
            
            selectedItems[matterIdString] = items
        }
        
        isLoading = false
    }
    
    private func saveRecord() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        // 删除当天的所有记录
        let existingRecords = try? modelContext.fetch(
            FetchDescriptor<MatterRecord>(
                predicate: #Predicate { record in
                    record.date >= startOfDay && record.date < endOfDay
                }
            )
        )
        
        for record in existingRecords ?? [] {
            modelContext.delete(record)
        }
        
        // 创建新记录
        for (matterIdString, items) in selectedItems {
            guard !items.isEmpty,
                  let matterId = UUID(uuidString: matterIdString),
                  let matter = matters.first(where: { $0.id == matterId }) else {
                continue
            }
            
            let record = MatterRecord(matterId: matterId, date: date)
            
            if matter.type == .singleSelect {
                // 单选：找到对应的选项ID
                if let selectedText = items.first,
                   let option = matter.options.first(where: { $0.displayText == selectedText }) {
                    record.singleOptionId = option.id
                }
            } else if matter.type == .multiSelect {
                // 多选：找到对应的选项ID列表
                let selectedOptionIds = matter.options.compactMap { option in
                    items.contains(option.displayText) ? option.id : nil
                }
                record.selectedOptionIds = selectedOptionIds
            }
            
            modelContext.insert(record)
        }
        
        try? modelContext.save()
    }
}

// MARK: - 事项编辑卡片
struct MatterEditCard: View {
    let matter: Matter
    @Binding var selectedItems: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: matter.icon)
                    .foregroundColor(matter.color)
                Text(matter.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // 选项
            if matter.type == .singleSelect {
                // 单选
                ForEach(matter.options, id: \.id) { option in
                    Button(action: {
                        selectedItems = [option.displayText]
                    }) {
                        HStack {
                            Image(systemName: selectedItems.contains(option.displayText) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedItems.contains(option.displayText) ? matter.color : .secondary)
                            Text(option.displayText)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                // 多选
                ForEach(matter.options, id: \.id) { option in
                    Button(action: {
                        if selectedItems.contains(option.displayText) {
                            selectedItems.removeAll { $0 == option.displayText }
                        } else {
                            selectedItems.append(option.displayText)
                        }
                    }) {
                        HStack {
                            Image(systemName: selectedItems.contains(option.displayText) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selectedItems.contains(option.displayText) ? matter.color : .secondary)
                            Text(option.displayText)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - 统计卡片（保留原有结构以兼容）
struct StatisticCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(14)
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let label: String
}

// MARK: - 趋势图表视图
struct TrendChartView: View {
    let data: [ChartDataPoint]
    let matter: Matter
    let viewMode: ChartViewMode
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            Chart(data) { dataPoint in
                AreaMark(
                    x: .value("日期", dataPoint.date),
                    y: .value("数值", dataPoint.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [matter.color.opacity(0.3), matter.color.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("日期", dataPoint.date),
                    y: .value("数值", dataPoint.value)
                )
                .foregroundStyle(matter.color)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                PointMark(
                    x: .value("日期", dataPoint.date),
                    y: .value("数值", dataPoint.value)
                )
                .foregroundStyle(matter.color)
                .symbolSize(60)
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let val = value.as(Double.self) {
                            Text(formatValue(val))
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: viewMode == .week ? .day : .weekOfYear)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                        .font(.caption)
                }
            }
            .frame(width: max(400, CGFloat(data.count) * 60))
            .padding(.horizontal, 16)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func formatValue(_ value: Double) -> String {
        // 根据数值返回对应的选项名称
        let intValue = Int(value)
        if intValue > 0 && intValue <= matter.options.count {
            return matter.options[intValue - 1].title
        }
        return "\(intValue)"
    }
}


// MARK: - 事项选择卡片
struct MatterSelectionCard: View {
    let matter: Matter
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: matter.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : matter.color)
                
                Text(matter.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? matter.color : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(matter.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
