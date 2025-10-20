//
//  BannerAndSummaryComponents.swift
//  Life
//
//  Created by tangxj on 10/13/25.
//

import SwiftUI
import UIKit

// MARK: - 保存成功顶部 Banner
struct SaveBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("已保存今日记录")
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 今日摘要卡片（迷你）
struct SummaryCard: View {
    let mood: String
    let location: String
    let keywords: [String]
    @State private var showCopied: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "face.smiling")
                    .foregroundColor(.orange)
                Text(mood)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Menu {
                    Button {
                        UIPasteboard.general.string = composedSummary
                        withAnimation(.easeInOut) { showCopied = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeInOut) { showCopied = false }
                        }
                    } label: {
                        Label("复制今日摘要", systemImage: "doc.on.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
                if !location.isEmpty {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text(location)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            if !keywords.isEmpty {
                let cols = [GridItem(.adaptive(minimum: 70), spacing: 6)]
                LazyVGrid(columns: cols, alignment: .leading, spacing: 6) {
                    ForEach(Array(keywords.prefix(4)), id: \.self) { kw in
                        Text(kw)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                    }
                }
            }
            if showCopied {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    Text("已复制到剪贴板").font(.caption).foregroundColor(.secondary)
                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var composedSummary: String {
        var parts: [String] = []
        parts.append("心情：\(mood)")
        if !location.isEmpty { parts.append("位置：\(location)") }
        if !keywords.isEmpty { parts.append("标签：\(keywords.joined(separator: ", "))") }
        return parts.joined(separator: "  |  ")
    }
}
