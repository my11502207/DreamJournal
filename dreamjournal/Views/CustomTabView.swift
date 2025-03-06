//
//  CustomTabView.swift
//  dreamjournal
//
//  Created by kevin on 2025/3/6.
//

import SwiftUI

// 自定义底部标签栏
    struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            Spacer()
            
            TabBarButton(title: "首页", icon: "house.fill", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            Spacer()
            
            TabBarButton(title: "历史", icon: "calendar", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            Spacer()
            
            TabBarButton(title: "分析", icon: "chart.pie.fill", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            
            Spacer()
        }
        .padding(.top, 10)
    }
}
