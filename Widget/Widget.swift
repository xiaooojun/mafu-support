//
//  Widget.swift
//  Widget
//
//  Created by tangxj on 10/16/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> LifeEntry {
        LifeEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> LifeEntry {
        LifeEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<LifeEntry> {
        var entries: [LifeEntry] = []

        // 每小时更新一次
        let currentDate = Date()
        for hourOffset in 0 ..< 24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = LifeEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct LifeEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct LifeWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - 小尺寸小组件
struct SmallWidgetView: View {
    let entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                Text("今日")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 4) {
                Text("心情")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("😊")
                    .font(.title)
            }
            
            Spacer()
            
            Text(Date(), style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - 中等尺寸小组件
struct MediumWidgetView: View {
    let entry: Provider.Entry
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧：心情和日期
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("今日生活")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("心情")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("😊 还不错")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text(Date(), style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 右侧：事项统计
            VStack(alignment: .trailing, spacing: 8) {
                Text("事项")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .foregroundColor(.indigo)
                            .font(.caption)
                        Text("睡眠")
                            .font(.caption)
                        Spacer()
                        Text("✓")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("心情")
                            .font(.caption)
                        Spacer()
                        Text("✓")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - 大尺寸小组件
struct LargeWidgetView: View {
    let entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            // 头部
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                Text("今日生活记录")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 心情区域
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日心情")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("😊 还不错")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // 事项列表
            VStack(spacing: 8) {
                Text("今日事项")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 6) {
                    MatterRow(icon: "moon.stars.fill", title: "睡眠", color: .indigo, isCompleted: true)
                    MatterRow(icon: "heart.fill", title: "心情", color: .red, isCompleted: true)
                    MatterRow(icon: "figure.run", title: "运动", color: .green, isCompleted: false)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - 事项行组件
struct MatterRow: View {
    let icon: String
    let title: String
    let color: Color
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            Text(title)
                .font(.caption)
            Spacer()
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
                .font(.caption)
        }
    }
}

struct TodayWidget: Widget {
    let kind: String = "TodayWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            LifeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("生活记录")
        .description("显示今日生活记录和事项完成情况")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var summary: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.displayMode = .summary
        return intent
    }
    
    fileprivate static var detailed: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.displayMode = .detailed
        return intent
    }
    
    fileprivate static var mood: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.displayMode = .mood
        return intent
    }
}

#Preview(as: .systemSmall) {
    TodayWidget()
} timeline: {
    LifeEntry(date: .now, configuration: .summary)
}

#Preview(as: .systemMedium) {
    TodayWidget()
} timeline: {
    LifeEntry(date: .now, configuration: .detailed)
}

#Preview(as: .systemLarge) {
    TodayWidget()
} timeline: {
    LifeEntry(date: .now, configuration: .mood)
}
