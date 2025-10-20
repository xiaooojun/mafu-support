//
//  AppIntent.swift
//  Widget
//
//  Created by tangxj on 10/16/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "生活记录小组件" }
    static var description: IntentDescription { "显示今日生活记录和事项完成情况" }

    // 小组件显示模式
    @Parameter(title: "显示模式", default: .summary)
    var displayMode: WidgetDisplayMode
}

enum WidgetDisplayMode: String, CaseIterable, AppEnum {
    case summary = "summary"
    case detailed = "detailed"
    case mood = "mood"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "显示模式"
    }
    
    static var caseDisplayRepresentations: [WidgetDisplayMode: DisplayRepresentation] {
        [
            .summary: "概览模式",
            .detailed: "详细模式", 
            .mood: "心情模式"
        ]
    }
}
