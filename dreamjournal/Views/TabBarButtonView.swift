//
//  TabBarView.swift
//  dreamjournal
//
//  Created by kevin on 2025/3/6.
//

import SwiftUI

// 标签栏按钮
struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color("AccentColor") : Color.clear)
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(isSelected ? .white : Color("SubtitleColor"))
                }
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : Color("SubtitleColor"))
            }
        }
    }
}
