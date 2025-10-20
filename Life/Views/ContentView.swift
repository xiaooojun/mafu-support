//
//  ContentView.swift
//  Life
//
//  Created by tangxj on 10/13/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dailyRecords: [DailyRecord]
    @State private var tabSelection: Int = 0
    
    private let appBackground = Color(.systemBackground)
    
    // iOS 26 优化：使用动态TabBar
    private let tabs = [
        DynamicTabBar.TabItem(icon: "calendar.day.timeline.left", title: "记录", tag: 0),
        DynamicTabBar.TabItem(icon: "chart.line.uptrend.xyaxis", title: "历史", tag: 1)
    ]
    
    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()
            
            TabView(selection: $tabSelection) {
                DailyRecordView()
                    .tag(0)
                DailyHistoryView()
                    .tag(1)
            }
            .toolbar(.hidden, for: .tabBar)
            .safeAreaInset(edge: .bottom) {
                DynamicTabBar(
                    selection: $tabSelection,
                    tabs: tabs,
                    backgroundColor: appBackground
                )
            }
            .accentColor(.blue)
            .background(appBackground)
            // iOS 26 优化：更好的键盘处理和安全区域适配
            .ignoresSafeArea(.keyboard, edges: .bottom)
            // iOS 26 新特性：支持动态岛和灵动岛
            .ignoresSafeArea(.container, edges: .top)
            // iOS 26 适配：应用导航栏样式
            .iOS26Adaptation(backgroundColor: appBackground)
        }
    }
}
 

