import SwiftUI
import SwiftData

struct OptionConfigView: View {
    @Binding var options: [MatterOption]
    @Environment(\.dismiss) private var dismiss
    let onComplete: (() -> Void)?
    
    @State private var newEmoji: String = ""
    @State private var newText: String = ""
    @State private var showingEmojiPicker = false
    @State private var editingEmojiIndex: Int? = nil
    @FocusState private var focusedRowIndex: Int?
    @FocusState private var isAddFieldFocused: Bool
    @State private var scrollTarget: Int? = nil
    private let titleMaxLength = 20
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        AddOptionCard(
                            newEmoji: $newEmoji,
                            newText: $newText,
                            editingEmojiIndex: $editingEmojiIndex,
                            showingEmojiPicker: $showingEmojiPicker,
                            isAddFieldFocused: $isAddFieldFocused,
                            onAdd: addOption
                        )
                        
                        if options.isEmpty {
                            EmptyStateCard()
                        } else {
                            OptionsListCard(
                                options: $options,
                                editingEmojiIndex: $editingEmojiIndex,
                                showingEmojiPicker: $showingEmojiPicker,
                                focusedRowIndex: $focusedRowIndex,
                                titleMaxLength: titleMaxLength
                            )
                        }
                    }
                    .padding(.horizontal)
                    .onChange(of: scrollTarget) { _, target in
                        guard let target else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(target, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .navigationTitle("选项配置")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("完成") { 
                        print("完成按钮被点击")
                        onComplete?()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // 自动聚焦到添加选项的输入框
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAddFieldFocused = true
            }
        }
        .onTapGesture {
            // 点击空白区域收起键盘
            isAddFieldFocused = false
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    // 滑动时收起键盘
                    isAddFieldFocused = false
                }
        )
        .sheet(isPresented: $showingEmojiPicker) {
            NavigationStack {
                EmojiGridView { selected in
                    if let idx = editingEmojiIndex {
                        options[idx].emoji = selected
                    } else {
                        newEmoji = selected
                    }
                    showingEmojiPicker = false
                }
                .navigationTitle("选择表情")
                #if canImport(UIKit)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("完成") { showingEmojiPicker = false }
                    }
                }
            }
        }
    }
    
    private func addOption() {
        let text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let emoji = newEmoji.isEmpty ? "😊" : newEmoji
        
        withAnimation(.easeInOut(duration: 0.2)) {
            options.append(MatterOption(emoji: emoji, title: text))
        }
        
        newEmoji = ""
        newText = ""
        
        // 让光标回到顶部输入框
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAddFieldFocused = true
        }
    }
}

private struct AddOptionCard: View {
    @Binding var newEmoji: String
    @Binding var newText: String
    @Binding var editingEmojiIndex: Int?
    @Binding var showingEmojiPicker: Bool
    @FocusState.Binding var isAddFieldFocused: Bool
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("添加新选项")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Button(action: {
                    editingEmojiIndex = nil
                    showingEmojiPicker = true
                }) {
                    Text(newEmoji.isEmpty ? "😊" : newEmoji)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                TextField("输入选项标题", text: $newText)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .submitLabel(.done)
                    .onSubmit { onAdd() }
                    .focused($isAddFieldFocused)
                
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .disabled(newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

private struct EmptyStateCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("还没有任何选项")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("点击上方区域添加你的第一个选项")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

private struct OptionsListCard: View {
    @Binding var options: [MatterOption]
    @Binding var editingEmojiIndex: Int?
    @Binding var showingEmojiPicker: Bool
    @FocusState.Binding var focusedRowIndex: Int?
    let titleMaxLength: Int
    
    var body: some View {
        List {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                OptionRowView(
                    option: Binding(
                        get: { options[index] },
                        set: { options[index] = $0 }
                    ),
                    index: index,
                    editingEmojiIndex: $editingEmojiIndex,
                    showingEmojiPicker: $showingEmojiPicker,
                    focusedRowIndex: $focusedRowIndex,
                    titleMaxLength: titleMaxLength,
                    onDelete: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            _ = options.remove(at: index)
                        }
                    }
                )
                .id(index)
                .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onMove { indices, newOffset in
                options.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .frame(height: CGFloat(options.count * 60 + 20))
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

private struct OptionRowView: View {
    @Binding var option: MatterOption
    let index: Int
    @Binding var editingEmojiIndex: Int?
    @Binding var showingEmojiPicker: Bool
    @FocusState.Binding var focusedRowIndex: Int?
    let titleMaxLength: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                editingEmojiIndex = index
                showingEmojiPicker = true
            }) {
                Text(option.emoji.isEmpty ? "😊" : option.emoji)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            
            TextField("选项标题", text: Binding(
                get: { option.title },
                set: { option.title = String($0.prefix(titleMaxLength)) }
            ))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .focused($focusedRowIndex, equals: index)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .id(index)
    }
}

private struct EmojiGridView: View {
    let onPick: (String) -> Void
    private let emojis: [String] = [
        "😊","😄","😀","🙂","😌","😉","🥰","🤔","😴","😭",
        "😡","😱","😓","🥳","🤒","🤧","🤕","🤯","🤓","😎",
        "✨","🔥","🌟","🌈","☀️","🌤️","🌧️","⛈️","❄️","🌪️",
        "🍎","🍊","🍌","🍉","🍇","🍓","🍒","🍑","🥝","🥑",
        "⚽️","🏀","🏈","🎾","🏓","🏸","🥊","🏐","🎳","🥏"
    ]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                ForEach(emojis, id: \.self) { e in
                    Button(action: { onPick(e) }) {
                        Text(e)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    OptionConfigView(
        options: .constant([
            MatterOption(emoji: "😊", title: "开心"),
            MatterOption(emoji: "😢", title: "难过")
        ]),
        onComplete: nil
    )
}
