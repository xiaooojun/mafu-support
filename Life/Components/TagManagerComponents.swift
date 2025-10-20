//
//  TagManagerComponents.swift
//  Life
//
//  Created by tangxj on 10/13/25.
//

import SwiftUI

// MARK: - 标签管理视图
struct TagManagerView: View {
    enum Category: String, CaseIterable { case emotion = "情绪", sleep = "睡眠", health = "健康", hobby = "爱好" }
    @Environment(\.dismiss) private var dismiss
    @State private var selected: Category
    @Binding var customEmotionItems: [String]
    @Binding var customSleepItems: [String]
    @Binding var customHealthItems: [String]
    @Binding var customHobbyItems: [String]
    @State private var newEmoji: String = ""
    @State private var newText: String = ""
    
    init(initialSelected: Category = .emotion,
         customEmotionItems: Binding<[String]>,
         customSleepItems: Binding<[String]>,
         customHealthItems: Binding<[String]>,
         customHobbyItems: Binding<[String]>) {
        _selected = State(initialValue: initialSelected)
        _customEmotionItems = customEmotionItems
        _customSleepItems = customSleepItems
        _customHealthItems = customHealthItems
        _customHobbyItems = customHobbyItems
    }
    
    private let emojiPalette: [String] = [
        "😀","😄","😊","🙂","😌","🙏","✨","🔆","💪","🏆",
        "😐","🧘","🧊","🎯","🧠","📚","🗒️","🕰️","🧩","📎",
        "😟","😬","😣","😔","😢","🥱","😡","😱","😓","🌫️",
        "💡","🍃","🌙","🌃","☀️","🕛","🏃","🥗","🍻","🤒"
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section("新增标签") {
                    VStack(alignment: .leading, spacing: 8) {
                        // 选中的表情预览 + 词语输入
                        HStack(spacing: 8) {
                            Text(newEmoji.isEmpty ? "⬜️" : newEmoji)
                                .frame(width: 36, height: 36)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            TextField("输入词语（如：开心）", text: $newText)
                                .disableAutocorrection(true)
                            Button("添加") { addItem() }
                                .disabled(newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        // 表情选择网格
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 8), spacing: 6) {
                            ForEach(emojiPalette, id: \.self) { e in
                                Text(e)
                                    .frame(maxWidth: .infinity)
                                    .padding(6)
                                    .background(newEmoji == e ? Color.blue.opacity(0.16) : Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .onTapGesture { newEmoji = e }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                Section("我的自定义") {
                    ForEach(currentBinding.wrappedValue, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("管理标签")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Picker("分类", selection: $selected) {
                        ForEach(Category.allCases, id: \.self) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 280)
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
    
    private var currentBinding: Binding<[String]> {
        switch selected {
        case .emotion: return $customEmotionItems
        case .sleep: return $customSleepItems
        case .health: return $customHealthItems
        case .hobby: return $customHobbyItems
        }
    }
    
    private func addItem() {
        let emoji = newEmoji.trimmingCharacters(in: .whitespacesAndNewlines)
        let text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let combined = (emoji.isEmpty ? "" : emoji + " ") + text
        if !currentBinding.wrappedValue.contains(combined) {
            currentBinding.wrappedValue.append(combined)
            persist()
        }
        newEmoji = ""; newText = ""
    }
    
    private func deleteItems(at offsets: IndexSet) {
        currentBinding.wrappedValue.remove(atOffsets: offsets)
        persist()
    }
    
    private func persist() {
        UserDefaults.standard.set(customEmotionItems, forKey: "customEmotionItems")
        UserDefaults.standard.set(customSleepItems, forKey: "customSleepItems")
        UserDefaults.standard.set(customHealthItems, forKey: "customHealthItems")
        UserDefaults.standard.set(customHobbyItems, forKey: "customHobbyItems")
    }
}
