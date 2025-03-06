//
//  TagView.swift
//  dreamjournal
//
//  Created by kevin on 2025/3/6.
//

import SwiftUI

// 标签组件
struct TagView: View {
    let tag: String
    let isSelected: Bool
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .foregroundColor(isSelected ? .white : Color("SubtitleColor"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .background(
            Capsule()
                .fill(isSelected ? Color("AccentColor").opacity(0.7) : Color("CardBackgroundColor"))
        )
        .overlay(
        Capsule()
                .stroke(isSelected ? Color.clear : Color("BorderColor"), lineWidth: 1)
        )
        .onTapGesture {
            onRemove()
        }
    }
}
