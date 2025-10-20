//
//  ArchiveComponents.swift
//  Life
//
//  Created by tangxj on 10/13/25.
//

import SwiftUI
import Combine

// MARK: - 归档选择视图
struct ArchivePickerView: View {
    @Binding var selection: String
    var onConfirm: (String) -> Void
    @StateObject private var archive = ArchiveManager.shared
    @State private var showingManage = false
    
    var body: some View {
        NavigationView {
            List {
                Section("选择归档到") {
                    ForEach(archive.folders, id: \.self) { folder in
                        HStack {
                            Text(folder)
                            Spacer()
                            if selection == folder {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { selection = folder }
                    }
                }
            }
            .listStyle(.inset)
            .navigationTitle("保存并归档")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("管理") { showingManage = true }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button("完成") { onConfirm(selection) }
                        .disabled(selection.isEmpty)
                }
            }
            .sheet(isPresented: $showingManage) {
                ArchiveManageView()
            }
        }
    }
}

final class ArchiveManager: ObservableObject {
    static let shared = ArchiveManager()
    @Published var folders: [String] {
        didSet { persist() }
    }
    private let key = "ArchiveFolders"
    private init() {
        if let saved = UserDefaults.standard.array(forKey: key) as? [String], !saved.isEmpty {
            folders = saved
        } else {
            folders = ["工作", "生活", "旅行", "学习", "其它"]
        }
    }
    private func persist() { UserDefaults.standard.set(folders, forKey: key) }
    func add(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !folders.contains(trimmed) else { return }
        folders.append(trimmed)
    }
    func remove(at offsets: IndexSet) { folders.remove(atOffsets: offsets) }
}

struct ArchiveManageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var archive = ArchiveManager.shared
    @State private var newFolder: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("新增文件夹") {
                    HStack {
                        TextField("输入名称", text: $newFolder)
                        Button("添加") {
                            archive.add(newFolder)
                            newFolder = ""
                        }
                        .disabled(newFolder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                Section("我的文件夹") {
                    ForEach(archive.folders, id: \.self) { name in
                        Text(name)
                    }
                    .onDelete(perform: archive.remove)
                }
            }
            .listStyle(.inset)
            .navigationTitle("管理归档")
            .toolbar {
                ToolbarItem(placement: .primaryAction) { Button("关闭") { dismiss() } }
                ToolbarItem(placement: .secondaryAction) { 
                    Button("编辑") { 
                        // macOS 版本的编辑功能
                    } 
                }
            }
        }
    }
}
