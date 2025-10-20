import SwiftUI
import SwiftData
import UIKit

struct DailyRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Matter> { $0.isEnabled == true }, sort: \.order) private var matters: [Matter]
    @Query private var matterRecords: [MatterRecord]
    @StateObject private var weatherManager = WeatherManager.shared
    
    @State private var selectedMood: String = "😊"
    @State private var showingSettings = false
    @State private var showingAddMatter = false
    @State private var editingMatter: Matter?
    @State private var viewingHistoryMatter: Matter?
    @State private var addingTestDataMatter: Matter?
    @State private var newlyAddedMatter: Matter?
    @State private var deletedMatterIndex: Int?
    @FocusState private var isAnyFieldFocused: Bool
    
    private let appBackground = Color(.systemBackground)
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.horizontal)
                        .frame(height: 100)
                        .background(appBackground)
                    
                    cardsSection
                }
            }
            .background(appBackground)
            .navigationTitle("生活记录")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        compactWeatherView
                        
                        Button {
                            // 添加新事项
                            showingAddMatter = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .onAppear {
                setupNavigationBar()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingAddMatter) {
                MatterEditView(
                    mode: .create,
                    onMatterCreated: { matter in
                        newlyAddedMatter = matter
                    },
                    onMatterDeleted: nil
                )
            }
            .sheet(item: $addingTestDataMatter) { matter in
                TestDataGeneratorView(matter: matter)
            }
            .sheet(item: $editingMatter) { matter in
                MatterEditView(
                    mode: .edit(matter),
                    onMatterCreated: nil,
                    onMatterDeleted: {
                        // 编辑模式下删除事项的处理
                        if let index = matters.firstIndex(where: { $0.id == matter.id }) {
                            deletedMatterIndex = max(0, index - 1)
                        }
                    }
                )
            }
            .sheet(item: $viewingHistoryMatter) { matter in
                MatterHistoryView(matter: matter)
            }
        }
        .background(appBackground)
    }
    
    private var cardsSection: some View {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Array(matters.filter { $0.isEnabled }.enumerated()), id: \.element.id) { index, matter in
                                    CardContainer(
                                        title: matter.title,
                                        leadingIcon: matter.icon,
                                        accentColor: matter.color,
                                        onEdit: { editingMatter = matter },
                                        onClear: nil,
                                        onHistory: { viewingHistoryMatter = matter },
                            onAddTestData: { addingTestDataMatter = matter },
                                        fixedHeight: 420
                                    ) {
                                        GenericMatterContent(matter: matter)
                                    }
                        .frame(width: 300)
                                    .id("card_\(index)")
                                }
                                
                }
                .padding(.horizontal, 40)
            }
            .background(appBackground)
            .scrollTargetBehavior(.viewAligned)
            .scrollTargetLayout()
            .frame(height: 440)
            .onAppear {
                scrollToFirstCard(proxy: proxy)
            }
            .onChange(of: matters) { oldMatters, newMatters in
                handleMattersChange(oldMatters: oldMatters, newMatters: newMatters, proxy: proxy)
            }
            .onChange(of: newlyAddedMatter) { _, newMatter in
                if let matter = newMatter {
                    scrollToMatter(matter: matter, proxy: proxy)
                    newlyAddedMatter = nil
                }
            }
            .onChange(of: deletedMatterIndex) { _, index in
                if let index = index {
                    scrollToCardAtIndex(index: index, proxy: proxy)
                    deletedMatterIndex = nil
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // 随机话语
            Text(dailyQuote)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // 居中的日期和星期（同一行）
            HStack(spacing: 8) {
                Text(todayDateString)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(todayWeekdayString)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .fontWeight(.medium)
            }
            
            moodSelector
        }
    }
    
    private var compactWeatherView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                if weatherManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else if let weather = weatherManager.weatherInfo {
                    Image(systemName: weather.conditionIcon)
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text("\(weather.temperature)°")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(weather.condition)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else if weatherManager.errorMessage != nil {
                    Button("天气") {
                        weatherManager.requestWeather()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                } else {
                    Button("天气") {
                        weatherManager.requestWeather()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            // 显示地理位置
            if let weather = weatherManager.weatherInfo, !weather.location.isEmpty {
                HStack(spacing: 4) {
                    Text(weather.location)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Button(action: {
                        weatherManager.forceRefreshLocation()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            if weatherManager.weatherInfo == nil && !weatherManager.isLoading {
                weatherManager.requestWeather()
            }
        }
    }
    
    private var dailyQuote: String {
        let baseQuotes = [
            "每一天都是新的开始",
            "记录生活，珍藏回忆",
            "时光荏苒，记录当下",
            "生活因记录而精彩",
            "每一个今天都值得纪念",
            "用心记录，用心生活",
            "时光不老，我们不散",
            "记录美好，分享快乐",
            "生活需要仪式感",
            "珍惜每一个平凡的日子",
            "让每一天都有意义",
            "记录成长，见证变化",
            "生活如诗，记录如画",
            "时光荏苒，记忆永恒",
            "记录生活，感悟人生",
            "每一天都是独特的",
            "用心感受，用笔记录",
            "生活因记录而美好",
            "时光匆匆，记录永恒",
            "记录今天，期待明天"
        ]
        
        // 使用日期作为种子，确保每天显示相同的话语
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let baseQuote = baseQuotes[dayOfYear % baseQuotes.count]
        
        // 如果有天气信息，添加天气相关的描述
        if let weather = weatherManager.weatherInfo {
            let weatherDescriptions = [
                "今天\(weather.condition)，\(weather.temperature)°",
                "\(weather.location)今日\(weather.condition) \(weather.temperature)°",
                "天气\(weather.condition)，温度\(weather.temperature)°",
                "今日\(weather.condition) \(weather.temperature)°"
            ]
            
            let weatherDesc = weatherDescriptions[dayOfYear % weatherDescriptions.count]
            return "\(baseQuote)\n\(weatherDesc)"
        }
        
        return baseQuote
    }
    
    private var todayDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日"
        return dateFormatter.string(from: Date())
    }
    
    private var todayWeekdayString: String {
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        weekdayFormatter.locale = Locale(identifier: "zh_CN")
        return weekdayFormatter.string(from: Date())
    }
    
    private var moodSelector: some View {
        EmptyView()
    }
    
    private func scrollToFirstCard(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let enabledMatters = matters.filter { $0.isEnabled }
            if !enabledMatters.isEmpty {
                proxy.scrollTo("card_0", anchor: UnitPoint.center)
            }
        }
    }
    
    private func handleMattersChange(oldMatters: [Matter], newMatters: [Matter], proxy: ScrollViewProxy) {
        // 检查是否有新添加的事项
        if newMatters.count > oldMatters.count {
            // 有新事项添加，找到最新的事项
            let newMatter = newMatters.first { matter in
                !oldMatters.contains { $0.id == matter.id }
            }
            if let matter = newMatter {
                newlyAddedMatter = matter
            }
        } else if newMatters.count < oldMatters.count {
            // 有事项被删除，找到被删除的事项索引
            let deletedMatter = oldMatters.first { oldMatter in
                !newMatters.contains { $0.id == oldMatter.id }
            }
            if let deletedMatter = deletedMatter {
                let index = oldMatters.firstIndex { $0.id == deletedMatter.id } ?? 0
                deletedMatterIndex = max(0, index - 1) // 跳转到前一个卡片
            }
        } else {
            // 事项数量相同，可能是编辑，保持当前位置
            scrollToFirstCard(proxy: proxy)
        }
    }
    
    private func scrollToMatter(matter: Matter, proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let enabledMatters = matters.filter { $0.isEnabled }
            if let index = enabledMatters.firstIndex(where: { $0.id == matter.id }) {
                proxy.scrollTo("card_\(index)", anchor: UnitPoint.center)
            }
        }
    }
    
    private func scrollToCardAtIndex(index: Int, proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let enabledMatters = matters.filter { $0.isEnabled }
            let targetIndex = min(index, enabledMatters.count - 1)
            if targetIndex >= 0 && targetIndex < enabledMatters.count {
                proxy.scrollTo("card_\(targetIndex)", anchor: UnitPoint.center)
            }
        }
    }
    
    private func setupNavigationBar() {
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

// MARK: - 测试数据生成器
struct TestDataGeneratorView: View {
    let matter: Matter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isGenerating = false
    @State private var generatedCount = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 50))
                            .foregroundColor(.blue)
                    
                    Text("生成测试数据")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("为「\(matter.title)」生成过去30天的随机数据")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("数据范围：")
                            .font(.headline)
                        Spacer()
                        Text("过去30天")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("生成数量：")
                            .font(.headline)
                        Spacer()
                        Text("30条记录")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("数据内容：")
                .font(.headline)
                        Spacer()
                        Text("随机选择选项")
                            .font(.subheadline)
                .foregroundColor(.secondary)
        }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                if isGenerating {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("正在生成数据...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("已生成 \(generatedCount) 条记录")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                
                Spacer()
                
                Button {
                    generateTestData()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("开始生成")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isGenerating)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle("测试数据")
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
    
    private func generateTestData() {
        isGenerating = true
        generatedCount = 0
        
        // 生成过去30天的数据
        let calendar = Calendar.current
        let today = Date()
        
        Task {
            for i in 0..<30 {
                let date = calendar.date(byAdding: .day, value: -i, to: today)!
                
                // 随机选择选项
                let randomOptions = generateRandomOptions(for: matter)
                
                let record = MatterRecord(matterId: matter.id, date: date)
                record.selectedOptionIds = Array(randomOptions)
                
                if matter.type == .singleSelect {
                    record.singleOptionId = randomOptions.first
                }
                
                modelContext.insert(record)
                generatedCount += 1
                
                // 添加小延迟让用户看到进度
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
            }
            
            try? modelContext.save()
            
            DispatchQueue.main.async {
                isGenerating = false
                dismiss()
            }
        }
    }
    
    private func generateRandomOptions(for matter: Matter) -> Set<UUID> {
        guard !matter.options.isEmpty else { return Set() }
        
        let optionCount = matter.options.count
        let maxSelections = min(optionCount, matter.type == .singleSelect ? 1 : Int.random(in: 1...optionCount))
        
        let shuffledOptions = matter.options.shuffled()
        let selectedOptions = Array(shuffledOptions.prefix(maxSelections))
        
        return Set(selectedOptions.map { $0.id })
    }
}

#Preview {
    DailyRecordView()
        .modelContainer(for: [Matter.self, MatterRecord.self])
}