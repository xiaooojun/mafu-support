import SwiftUI
import SwiftData
import UIKit

struct MatterHistoryView: View {
    let matter: Matter
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var matterRecords: [MatterRecord]
    
    private let appBackground = Color.gray.opacity(0.1)
    
    // 顶部分段：日历/图表
    enum TopSwitcher: String, CaseIterable {
        case calendar = "日历"
        case chart = "图表"
    }
    @State private var topSwitcher: TopSwitcher = .calendar
    
    @State private var selectedTimeRange: TimeRange = .month
    
    // 根据选择的时间范围过滤记录
    private var filteredRecords: [MatterRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        let baseRecords: [MatterRecord]
        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            baseRecords = matterRecords.filter { $0.matterId == matter.id && $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            baseRecords = matterRecords.filter { $0.matterId == matter.id && $0.date >= monthAgo }
        case .all:
            baseRecords = matterRecords.filter { $0.matterId == matter.id }
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
    
    // 生成选项统计数据（用于图表）
    private func buildOptionStats(records: [MatterRecord], matter: Matter) -> [OptionStatistic] {
        var stats: [String: Int] = [:]
        for record in records {
            if let singleOptionId = record.singleOptionId,
               let option = matter.options.first(where: { $0.id == singleOptionId }) {
                stats[option.title, default: 0] += 1
            } else if !record.selectedOptionIds.isEmpty {
                let selectedOptions = matter.options.filter { record.selectedOptionIds.contains($0.id) }
                let label = selectedOptions.map { $0.title }.joined(separator: ", ")
                stats[label, default: 0] += 1
            } else {
                stats["未选择", default: 0] += 1
            }
        }
        return stats.map { OptionStatistic(label: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    // 为不同选项分配不同颜色
    private func colorForOption(_ optionLabel: String) -> Color {
        let colors: [Color] = [
            matter.color,
            Color.blue,
            Color.green,
            Color.orange,
            Color.purple,
            Color.red,
            Color.pink,
            Color.teal,
            Color.indigo,
            Color.mint
        ]
        
        // 使用选项名称的哈希值来选择颜色，确保相同选项总是相同颜色
        let hash = abs(optionLabel.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    // MARK: - 顶部切换：日历/图表
                    Picker("视图", selection: $topSwitcher) {
                        ForEach(TopSwitcher.allCases, id: \.self) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    // MARK: - 主要内容区域
                    if !filteredRecords.isEmpty {
                        VStack(spacing: 12) {
                            // 顶部切换的内容区域
                            Group {
                                if topSwitcher == .calendar {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("选择记录")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            // 时间筛选菜单
                                            Menu {
                                                Button("最近一周") { selectedTimeRange = .week }
                                                Button("最近一月") { selectedTimeRange = .month }
                                                Button("全部") { selectedTimeRange = .all }
                                            } label: {
                                                Label(selectedTimeRange.rawValue, systemImage: "line.3.horizontal.decrease.circle")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        CalendarView(
                                            records: filteredRecords,
                                            matter: matter
                                        )
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("图表")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            // 时间筛选菜单
                                            Menu {
                                                Button("最近一周") { selectedTimeRange = .week }
                                                Button("最近一月") { selectedTimeRange = .month }
                                                Button("全部") { selectedTimeRange = .all }
                                            } label: {
                                                Label(selectedTimeRange.rawValue, systemImage: "line.3.horizontal.decrease.circle")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        // 使用大饼图 + 图例
                                        let stats = buildOptionStats(records: filteredRecords, matter: matter)
                                        ChartView(stats: stats, matter: matter, colorForOption: colorForOption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // 记录列表
                            VStack(spacing: 16) {
                                Text("记录列表")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                LazyVStack(spacing: 8) {
                                    ForEach(filteredRecords.sorted { $0.date > $1.date }, id: \.id) { record in
                                        RecordListItem(record: record, matter: matter)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    } else {
                        emptyState
                    }
                }
                .padding(.bottom, 20)
            }
            .background(appBackground)
            .navigationTitle(matter.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // iOS 26 优化：更精细的导航栏外观控制
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(appBackground)
                appearance.shadowColor = .clear
                
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
                
                UINavigationBar.appearance().prefersLargeTitles = true
                UINavigationBar.appearance().isTranslucent = false
                UINavigationBar.appearance().barTintColor = UIColor(appBackground)
            }
        }
        .background(appBackground)
    }
    
    // MARK: - 统计概览
    private var statisticsOverview: some View {
        VStack(spacing: 16) {
            // 记录天数卡片
            HStack {
                StatisticCard(
                    title: "记录天数",
                    value: "\(filteredRecords.count)",
                    color: .green,
                    icon: "calendar"
                )
                Spacer()
            }
            
            // 选项统计饼状图
            VStack(alignment: .leading, spacing: 12) {
                Text("选项统计")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                OptionPieChart(
                    records: filteredRecords,
                    matter: matter
                )
            }
        }
    }
    
    // 获取唯一选项数量
    private func getUniqueOptionsCount() -> Int {
        let allLabels = filteredRecords.compactMap { record in
            getOptionLabel(from: record)
        }
        return Set(allLabels).count
    }
    
    // 从MatterRecord中获取选项标签（用于图表显示）
    private func getOptionLabel(from record: MatterRecord) -> String {
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
        ContentUnavailableView("暂无记录", systemImage: "tray.fill", description: Text("开始记录\(matter.title)数据吧！"))
    }
    
    // MARK: - 日历视图
    struct CalendarView: View {
        let records: [MatterRecord]
        let matter: Matter
        
        @State private var selectedDate = Date()
        @State private var showingDetailSheet = false
        @State private var selectedRecord: MatterRecord? = nil
        
        private var calendar = Calendar.current
        private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月"
            return formatter
        }()
        
        init(records: [MatterRecord], matter: Matter, calendar: Calendar = Calendar.current) {
            self.records = records
            self.matter = matter
            self.calendar = calendar
        }
        
        var body: some View {
            VStack(spacing: 16) {
                // 月份标题和导航
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(matter.color)
                    }
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(matter.color)
                    }
                }
                .padding(.horizontal)
                
                // 星期标题
                HStack {
                    ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // 日历网格
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(daysInMonth, id: \.self) { date in
                        let isCurrentMonth = calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
                        DayCell(
                            date: date,
                            record: isCurrentMonth ? recordForDate(date) : nil,
                            matter: matter,
                            isCurrentMonth: isCurrentMonth,
                            onTap: { record in
                                selectedRecord = record
                                showingDetailSheet = true
                            }
                        )
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            .sheet(isPresented: $showingDetailSheet) {
                if let record = selectedRecord {
                    DayDetailView(record: record, matter: matter)
                }
            }
        }
        
        private var daysInMonth: [Date] {
            guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
                return []
            }
            
            // 获取月份的第一天和最后一天
            let monthStart = monthInterval.start
            let monthEnd = monthInterval.end - 1
            
            // 计算这个月第一天是星期几（1=周一，7=周日）
            let weekday = calendar.component(.weekday, from: monthStart)
            let weekdayFromMonday = weekday == 1 ? 7 : weekday - 1 // 转换为从周一开始的索引
            
            // 计算日历开始日期（从周一开始）
            let calendarStart = calendar.date(byAdding: .day, value: -(weekdayFromMonday - 1), to: monthStart) ?? monthStart
            
            // 计算这个月最后一天是星期几
            let lastWeekday = calendar.component(.weekday, from: monthEnd)
            let lastWeekdayFromMonday = lastWeekday == 1 ? 7 : lastWeekday - 1
            
            // 计算日历结束日期（到周日结束）
            let calendarEnd = calendar.date(byAdding: .day, value: (7 - lastWeekdayFromMonday), to: monthEnd) ?? monthEnd
            
            // 生成日期
            var days: [Date] = []
            var currentDate = calendarStart
            
            while currentDate <= calendarEnd {
                days.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            
            return days
        }
        
        private func recordForDate(_ date: Date) -> MatterRecord? {
            return records.first { record in
                calendar.isDate(record.date, inSameDayAs: date)
            }
        }
        
        private func previousMonth() {
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        }
        
        private func nextMonth() {
            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        }
        
        // MARK: - 日期单元格
        struct DayCell: View {
            let date: Date
            let record: MatterRecord?
            let matter: Matter
            let isCurrentMonth: Bool
            let onTap: (MatterRecord?) -> Void
            
            private var dayFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "d"
                return formatter
            }()
            
            private var calendar = Calendar.current
            
            private var isToday: Bool {
                calendar.isDateInToday(date)
            }
            
            init(date: Date, record: MatterRecord?, matter: Matter, isCurrentMonth: Bool, onTap: @escaping (MatterRecord?) -> Void, dayFormatter: DateFormatter = DateFormatter()) {
                self.date = date
                self.record = record
                self.matter = matter
                self.isCurrentMonth = isCurrentMonth
                self.onTap = onTap
                self.dayFormatter = dayFormatter
                self.dayFormatter.dateFormat = "d"
            }
            
            var body: some View {
                VStack(spacing: 2) {
                    // 日期数字
                    Text(dayFormatter.string(from: date))
                        .font(.caption)
                        .fontWeight(isToday ? .bold : .medium)
                        .foregroundColor(isToday ? .white : (isCurrentMonth ? .primary : .secondary))
                    
                    // 选项显示
                    if let record = record {
                        optionIndicator
                    }
                }
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundFill)
                )
                .onTapGesture {
                    onTap(record)
                }
            }
            
            private var backgroundFill: Color {
                if isToday {
                    return matter.color
                } else if record != nil {
                    return matter.color.opacity(0.1)
                } else {
                    return Color.clear
                }
            }
            
            @ViewBuilder
            private var optionIndicator: some View {
                if let record = record {
                    if let singleOptionId = record.singleOptionId,
                       let option = matter.options.first(where: { $0.id == singleOptionId }) {
                        // 单选：显示选项的第一个字符或emoji
                        Text(getOptionDisplayText(option.title))
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(matter.color)
                            .clipShape(Circle())
                    } else if !record.selectedOptionIds.isEmpty {
                        // 多选：显示选中数量
                        let count = record.selectedOptionIds.count
                        Text("\(count)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(matter.color)
                            .clipShape(Circle())
                    }
                }
            }
            
            private func getOptionDisplayText(_ title: String) -> String {
                // 如果选项标题包含emoji，返回第一个字符
                if let firstChar = title.first {
                    return String(firstChar)
                }
                return "✓"
            }
        }
    }
    
    // MARK: - 记录列表项
    struct RecordListItem: View {
        let record: MatterRecord
        let matter: Matter
        
        private var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日 EEEE"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter
        }()
        
        init(record: MatterRecord, matter: Matter, dateFormatter: DateFormatter = DateFormatter()) {
            self.record = record
            self.matter = matter
            self.dateFormatter = dateFormatter
            self.dateFormatter.dateFormat = "MM月dd日 EEEE"
            self.dateFormatter.locale = Locale(identifier: "zh_CN")
        }
        
        var body: some View {
            HStack(spacing: 12) {
                // 日期
                VStack(alignment: .leading, spacing: 2) {
                    Text(dateFormatter.string(from: record.date))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(formatTime(record.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 选项内容
                VStack(alignment: .trailing, spacing: 2) {
                    Text(getOptionLabel(from: record))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                    
                    Text(matter.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 颜色指示器
                Circle()
                    .fill(matter.color)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        
        private func getOptionLabel(from record: MatterRecord) -> String {
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
        
        private func formatTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
    }
}

// MARK: - 日期详情视图
struct DayDetailView: View {
    let record: MatterRecord
    let matter: Matter
    @Environment(\.dismiss) private var dismiss
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    init(record: MatterRecord, matter: Matter) {
        self.record = record
        self.matter = matter
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 日期标题
                VStack(spacing: 8) {
                    Text(dateFormatter.string(from: record.date))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(matter.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // 选项详情
                VStack(alignment: .leading, spacing: 16) {
                    Text("选择详情")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let singleOptionId = record.singleOptionId,
                       let option = matter.options.first(where: { $0.id == singleOptionId }) {
                        // 单选显示
                        HStack {
                            Circle()
                                .fill(matter.color)
                                .frame(width: 12, height: 12)
                            
                            Text(option.title)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    } else if !record.selectedOptionIds.isEmpty {
                        // 多选显示
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(record.selectedOptionIds, id: \.self) { optionId in
                                if let option = matter.options.first(where: { $0.id == optionId }) {
                                    HStack {
                                        Circle()
                                            .fill(matter.color)
                                            .frame(width: 12, height: 12)
                                        
                                        Text(option.title)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    } else {
                        // 无选择
                        Text("未选择任何选项")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color(.systemBackground))
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
}

// MARK: - 紧凑统计卡片
struct CompactStatisticsCard: View {
    let records: [MatterRecord]
    let matter: Matter
    
    private var optionStats: [OptionStatistic] {
        var stats: [String: Int] = [:]
        
        for record in records {
            let optionLabel = getOptionLabel(from: record)
            stats[optionLabel, default: 0] += 1
        }
        
        return stats.map { OptionStatistic(label: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 记录天数文字说明
            HStack {
                Text("记录天数")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(records.count)天")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            
            // 饼状图和说明
            if !optionStats.isEmpty {
                VStack(spacing: 12) {
                    SmallPieChart(optionStats: optionStats, matter: matter)
                        .frame(width: 120, height: 120)
                    
                    OptionLegendCompact(optionStats: optionStats, matter: matter)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    private func getOptionLabel(from record: MatterRecord) -> String {
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
}

// MARK: - 小饼状图
struct SmallPieChart: View {
    let optionStats: [OptionStatistic]
    let matter: Matter
    
    private var totalCount: Int {
        optionStats.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        ZStack {
            ForEach(Array(optionStats.enumerated()), id: \.element.id) { index, stat in
                SmallPieSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: colorForOption(stat.label)
                )
            }
        }
        .frame(width: 140, height: 140)
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousCount = optionStats.prefix(index).reduce(0) { $0 + $1.count }
        return Angle(degrees: Double(previousCount) / Double(totalCount) * 360)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let currentCount = optionStats.prefix(index + 1).reduce(0) { $0 + $1.count }
        return Angle(degrees: Double(currentCount) / Double(totalCount) * 360)
    }
    
    private func colorForOption(_ optionLabel: String) -> Color {
        // 为不同选项分配不同颜色
        let colors: [Color] = [
            matter.color,
            Color.blue,
            Color.green,
            Color.orange,
            Color.purple,
            Color.red,
            Color.pink,
            Color.teal,
            Color.indigo,
            Color.mint
        ]
        
        // 使用选项名称的哈希值来选择颜色，确保相同选项总是相同颜色
        let hash = abs(optionLabel.hashValue)
        return colors[hash % colors.count]
    }
}

// MARK: - 小饼状图扇形
struct SmallPieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 70, y: 70)
            let radius: CGFloat = 60
            
            path.move(to: center)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            path.closeSubpath()
        }
        .fill(color)
        .stroke(Color.white, lineWidth: 1.5)
    }
}

// MARK: - 紧凑选项图例
struct OptionLegendCompact: View {
    let optionStats: [OptionStatistic]
    let matter: Matter
    
    private var totalCount: Int {
        optionStats.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(Array(optionStats.prefix(4).enumerated()), id: \.element.id) { index, stat in
                HStack(spacing: 6) {
                    // 颜色指示器
                    Circle()
                        .fill(colorForIndex(index))
                        .frame(width: 8, height: 8)
                    
                    // 选项名称
                    Text(stat.label)
                        .font(.caption2)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 占比
                    Text("\(Int(Double(stat.count) / Double(totalCount) * 100))%")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            // 如果有更多选项，显示省略号
            if optionStats.count > 4 {
                HStack {
                    Text("...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("共\(optionStats.count)种")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [
            matter.color,
            Color.blue,
            Color.green,
            Color.orange,
            Color.purple,
            Color.red,
            Color.pink,
            Color.teal,
            Color.indigo,
            Color.mint
        ]
        return colors[index % colors.count]
    }
}

// MARK: - 统计概览卡片
struct StatisticsOverviewCard: View {
    let records: [MatterRecord]
    let matter: Matter
    let onTapStatistics: () -> Void
    
    private var optionStats: [OptionStatistic] {
        var stats: [String: Int] = [:]
        
        for record in records {
            let optionLabel = getOptionLabel(from: record)
            stats[optionLabel, default: 0] += 1
        }
        
        return stats.map { OptionStatistic(label: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("数据统计")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    onTapStatistics()
                } label: {
                    HStack(spacing: 4) {
                        Text("查看详情")
                            .font(.subheadline)
                            .foregroundColor(matter.color)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(matter.color)
                    }
                }
            }
            
            VStack(spacing: 12) {
                // 记录天数卡片
                StatisticCard(
                    title: "记录天数",
                    value: "\(records.count)",
                    color: .green,
                    icon: "calendar"
                )
                
                // 选项种类列表
                if !optionStats.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("选项分布")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        OptionTypesList(optionStats: optionStats, matter: matter)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func getOptionLabel(from record: MatterRecord) -> String {
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
}

// MARK: - 选项种类列表
struct OptionTypesList: View {
    let optionStats: [OptionStatistic]
    let matter: Matter
    
    private var totalCount: Int {
        optionStats.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(Array(optionStats.enumerated()), id: \.element.id) { index, stat in
                HStack {
                    // 颜色指示器
                    Circle()
                        .fill(colorForOption(stat.label))
                        .frame(width: 10, height: 10)
                    
                    // 选项名称
                    Text(stat.label)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 天数和占比
                    HStack(spacing: 4) {
                        Text("\(stat.count)天")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("(\(Int(Double(stat.count) / Double(totalCount) * 100))%)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemBackground))
                .cornerRadius(6)
            }
        }
    }
    
    private func colorForOption(_ optionLabel: String) -> Color {
        // 为不同选项分配不同颜色
        let colors: [Color] = [
            matter.color,
            Color.blue,
            Color.green,
            Color.orange,
            Color.purple,
            Color.red,
            Color.pink,
            Color.teal,
            Color.indigo,
            Color.mint
        ]
        
        // 使用选项名称的哈希值来选择颜色，确保相同选项总是相同颜色
        let hash = abs(optionLabel.hashValue)
        return colors[hash % colors.count]
    }
}

// MARK: - 统计详情视图
struct StatisticsDetailView: View {
    let records: [MatterRecord]
    let matter: Matter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 饼状图
                    OptionPieChart(
                        records: records,
                        matter: matter
                    )
                    .padding(.horizontal)
                    
                    // 详细统计列表
                    DetailedStatisticsList(
                        records: records,
                        matter: matter
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground))
            .navigationTitle("数据统计")
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
}

// MARK: - 详细统计列表
struct DetailedStatisticsList: View {
    let records: [MatterRecord]
    let matter: Matter
    
    private var optionStats: [OptionStatistic] {
        var stats: [String: Int] = [:]
        
        for record in records {
            let optionLabel = getOptionLabel(from: record)
            stats[optionLabel, default: 0] += 1
        }
        
        return stats.map { OptionStatistic(label: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    private var totalCount: Int {
        records.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("详细统计")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(Array(optionStats.enumerated()), id: \.element.id) { index, stat in
                    HStack {
                        // 颜色指示器
                        Circle()
                            .fill(colorForIndex(index))
                            .frame(width: 12, height: 12)
                        
                        // 选项名称
                        Text(stat.label)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // 天数和占比
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(stat.count)天")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("\(Int(Double(stat.count) / Double(totalCount) * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func getOptionLabel(from record: MatterRecord) -> String {
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
    
    private func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [
            matter.color,
            matter.color.opacity(0.8),
            matter.color.opacity(0.6),
            matter.color.opacity(0.4),
            Color.blue,
            Color.green,
            Color.orange,
            Color.purple,
            Color.red,
            Color.pink
        ]
        return colors[index % colors.count]
    }
}

// MARK: - 紧凑统计视图
struct CompactStatisticsView: View {
    let records: [MatterRecord]
    let matter: Matter
    
    private var optionStats: [OptionStatistic] {
        var stats: [String: Int] = [:]
        
        for record in records {
            let optionLabel = getOptionLabel(from: record)
            stats[optionLabel, default: 0] += 1
        }
        
        return stats.map { OptionStatistic(label: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    private var totalCount: Int {
        records.count
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 记录天数卡片
            StatisticCard(
                title: "记录天数",
                value: "\(totalCount)",
                color: .green,
                icon: "calendar"
            )
            
            // 紧凑的选项统计
            if !optionStats.isEmpty {
                VStack(spacing: 8) {
                    Text("选项分布")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    CompactOptionList(optionStats: optionStats, matter: matter)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    private func getOptionLabel(from record: MatterRecord) -> String {
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
}

// MARK: - 紧凑选项列表
struct CompactOptionList: View {
    let optionStats: [OptionStatistic]
    let matter: Matter
    
    private var totalCount: Int {
        optionStats.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(Array(optionStats.prefix(5).enumerated()), id: \.element.id) { index, stat in
                HStack {
                    // 颜色指示器
                    Circle()
                        .fill(colorForIndex(index))
                        .frame(width: 8, height: 8)
                    
                    // 选项名称
                    Text(stat.label)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 占比
                    Text("\(Int(Double(stat.count) / Double(totalCount) * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            // 如果有更多选项，显示省略号
            if optionStats.count > 5 {
                HStack {
                    Text("...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("共\(optionStats.count)种")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [
            matter.color,
            matter.color.opacity(0.8),
            matter.color.opacity(0.6),
            matter.color.opacity(0.4),
            Color.blue,
            Color.green,
            Color.orange,
            Color.purple,
            Color.red,
            Color.pink
        ]
        return colors[index % colors.count]
    }
}

// MARK: - 选项饼状图
struct OptionPieChart: View {
    let records: [MatterRecord]
    let matter: Matter
    
    private var optionStats: [OptionStatistic] {
        var stats: [String: Int] = [:]
        
        for record in records {
            let optionLabel = getOptionLabel(from: record)
            stats[optionLabel, default: 0] += 1
        }
        
        return stats.map { OptionStatistic(label: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if !optionStats.isEmpty {
                // 饼状图
                PieChartView(optionStats: optionStats, matter: matter)
                    .frame(height: 200)
                
                // 图例
                OptionLegend(optionStats: optionStats, matter: matter)
            } else {
                // 无数据状态
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("暂无数据")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func getOptionLabel(from record: MatterRecord) -> String {
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
}

// MARK: - 选项统计数据
struct OptionStatistic: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
}

// MARK: - 饼状图视图
struct PieChartView: View {
    let optionStats: [OptionStatistic]
    let matter: Matter
    
    private var totalCount: Int {
        optionStats.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        ZStack {
            ForEach(Array(optionStats.enumerated()), id: \.element.id) { index, stat in
                PieSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: colorForIndex(index)
                )
            }
            
            // 中心文字
            VStack {
                Text("总计")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(totalCount)天")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousCount = optionStats.prefix(index).reduce(0) { $0 + $1.count }
        return Angle(degrees: Double(previousCount) / Double(totalCount) * 360)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let currentCount = optionStats.prefix(index + 1).reduce(0) { $0 + $1.count }
        return Angle(degrees: Double(currentCount) / Double(totalCount) * 360)
    }
    
    private func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [
            matter.color,
            matter.color.opacity(0.8),
            matter.color.opacity(0.6),
            matter.color.opacity(0.4),
            Color.blue,
            Color.green,
            Color.orange,
            Color.purple,
            Color.red,
            Color.pink
        ]
        return colors[index % colors.count]
    }
}

// MARK: - 饼状图扇形
struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 100, y: 100)
            let radius: CGFloat = 80
            
            path.move(to: center)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            path.closeSubpath()
        }
        .fill(color)
        .stroke(Color.white, lineWidth: 2)
    }
}

// MARK: - 图例
struct OptionLegend: View {
    let optionStats: [OptionStatistic]
    let matter: Matter
    
    private var totalCount: Int {
        optionStats.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(optionStats.enumerated()), id: \.element.id) { index, stat in
                HStack {
                    // 颜色指示器
                    Circle()
                        .fill(colorForIndex(index))
                        .frame(width: 12, height: 12)
                    
                    // 选项名称
                    Text(stat.label)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 天数和占比
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(stat.count)天")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("\(Int(Double(stat.count) / Double(totalCount) * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
        }
    }
    
    private func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [
            matter.color,
            matter.color.opacity(0.8),
            matter.color.opacity(0.6),
            matter.color.opacity(0.4),
            Color.blue,
            Color.green,
            Color.orange,
            Color.purple,
            Color.red,
            Color.pink
        ]
        return colors[index % colors.count]
    }
}

// MARK: - 图表视图
struct ChartView: View {
    let stats: [OptionStatistic]
    let matter: Matter
    let colorForOption: (String) -> Color
    
    private var totalCount: Int {
        stats.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // 饼图
            SmallPieChart(optionStats: stats, matter: matter)
            
            // 图例
            VStack(alignment: .leading, spacing: 3) {
                ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                    let percentage = totalCount > 0 ? Int(Double(stat.count) / Double(totalCount) * 100) : 0
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(colorForOption(stat.label))
                            .frame(width: 8, height: 8)
                        
                        Text(stat.label)
                            .font(.caption2)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(stat.count)天")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("(\(percentage)%)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    MatterHistoryView(matter: Matter(title: "睡眠", icon: "moon.fill", type: .singleSelect, options: []))
        .modelContainer(for: MatterRecord.self, inMemory: true)
}