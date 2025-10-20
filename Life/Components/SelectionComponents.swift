//
//  SelectionComponents.swift
//  Life
//
//  Created by tangxj on 10/13/25.
//

import SwiftUI

// MARK: - 点选式列表组件（单/多选）
struct SelectableList: View {
    let items: [String]
    @Binding var selection: Set<String>
    var allowMultiple: Bool = true
    var accentColor: Color = .blue
    var onLongPressRemove: ((String) -> Void)? = nil
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 8) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let isOn = selection.contains(item)
                    Button {
                        if allowMultiple {
                            if isOn { selection.remove(item) } else { selection.insert(item) }
                        } else {
                            if isOn { selection.removeAll() } else { selection = [item] }
                        }
                    } label: {
                        HStack {
                            Text(item)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                            Spacer()
                            SelectionIndicator(isSelected: isOn, accent: accentColor)
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if let onRemove = onLongPressRemove {
                            Button(role: .destructive) { onRemove(item) } label: {
                                Label("删除自定义", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - 水平滚动选择组件
struct HorizontalSelectableList: View {
    let items: [String]
    @Binding var selection: Set<String>
    var allowMultiple: Bool = true
    var accentColor: Color = .blue
    var onLongPressRemove: ((String) -> Void)? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let isOn = selection.contains(item)
                    Button {
                        if allowMultiple {
                            if isOn { selection.remove(item) } else { selection.insert(item) }
                        } else {
                            if isOn { selection.removeAll() } else { selection = [item] }
                        }
                    } label: {
                        Text(item)
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isOn ? Color.blue.opacity(0.16) : Color.gray.opacity(0.1))
                            .foregroundColor(isOn ? .blue : .primary)
                            .cornerRadius(18)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if let onRemove = onLongPressRemove {
                            Button(role: .destructive) { onRemove(item) } label: {
                                Label("删除自定义", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - 选择指示器
private struct SelectionIndicator: View {
    let isSelected: Bool
    var accent: Color = .blue
    var body: some View {
        ZStack {
            Circle().strokeBorder(isSelected ? accent : Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 22, height: 22)
            if isSelected {
                Circle().fill(accent).frame(width: 12, height: 12)
            }
        }
    }
}

// MARK: - 单选组件
struct SingleSelectList: View {
    let items: [String]
    @Binding var selection: String?
    var accentColor: Color = .blue
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                let isSelected = selection == item
                Button {
                    selection = isSelected ? nil : item
                } label: {
                    HStack {
                        Text(item)
                            .foregroundColor(.primary)
                        Spacer()
                        SelectionIndicator(isSelected: isSelected, accent: accentColor)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - 多选组件
struct MultiSelectList: View {
    let items: [String]
    @Binding var selection: Set<String>
    var accentColor: Color = .blue
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                let isSelected = selection.contains(item)
                Button {
                    if isSelected {
                        selection.remove(item)
                    } else {
                        selection.insert(item)
                    }
                } label: {
                    HStack {
                        Text(item)
                            .foregroundColor(.primary)
                        Spacer()
                        SelectionIndicator(isSelected: isSelected, accent: accentColor)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }
}