import SwiftUI

struct DreamHistoryView: View {
    @State private var filterOption: FilterOption = .all
    @State private var searchText: String = ""
    @State private var isGridView: Bool = false
    @State private var dreams: [Dream] = [
        Dream(id: "1", title: "飞行梦", description: "我梦见自己在城市上空飞行，感觉非常自由...", date: Date(), clarity: 8, emotion: "😮", tags: ["飞行", "城市", "自由"]),
        Dream(id: "2", title: "迷宫梦", description: "在一个复杂的迷宫中寻找出口，墙壁不断变化...", date: Date().addingTimeInterval(-86400), clarity: 6, emotion: "😨", tags: ["迷宫", "寻找", "恐惧"]),
        Dream(id: "3", title: "海边漫步", description: "我梦见自己在一个安静的海滩上漫步，海浪声非常清晰...", date: Date().addingTimeInterval(-3*86400), clarity: 9, emotion: "😌", tags: ["海滩", "平静", "水"]),
        Dream(id: "4", title: "古老图书馆", description: "在一个巨大的古代图书馆中探索，书架高耸入云...", date: Date().addingTimeInterval(-7*86400), clarity: 3, emotion: "🤔", tags: ["图书馆", "探索", "知识"])
    ]
    
    // 筛选选项
    enum FilterOption: String, CaseIterable {
        case all = "全部"
        case tags = "标签"
        case emotions = "情绪"
    }
    
    var filteredDreams: [Dream] {
        if searchText.isEmpty {
            return dreams
        } else {
            return dreams.filter { dream in
                dream.title.localizedCaseInsensitiveContains(searchText) ||
                dream.description.localizedCaseInsensitiveContains(searchText) ||
                dream.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // 搜索栏
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // 筛选选项
                    FilterBar(selectedFilter: $filterOption)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    
                    // 视图切换
                    HStack {
                        Spacer()
                        
                        ViewToggle(isGridView: $isGridView)
                            .padding(.trailing)
                            .padding(.top, 8)
                    }
                    
                    // 梦境列表
                    if isGridView {
                        DreamGrid(dreams: filteredDreams)
                            .padding(.top, 12)
                    } else {
                        DreamList(dreams: filteredDreams)
                            .padding(.top, 12)
                    }
                }
                
                
            }
            .navigationTitle("梦境历史")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// 搜索栏组件
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("SubtitleColor"))
            
            TextField("搜索梦境...", text: $text)
                .foregroundColor(.white)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("SubtitleColor"))
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("CardBackgroundColor"))
        )
    }
}

// 筛选栏组件
struct FilterBar: View {
    @Binding var selectedFilter: DreamHistoryView.FilterOption
    
    var body: some View {
        HStack {
            Text("筛选: ")
                .font(.subheadline)
                .foregroundColor(Color("SubtitleColor"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DreamHistoryView.FilterOption.allCases, id: \.self) { option in
                        FilterButton(
                            title: option.rawValue,
                            isSelected: selectedFilter == option,
                            action: { selectedFilter = option }
                        )
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("CardBackgroundColor"))
        )
    }
}

// 筛选按钮组件
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .medium : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color("AccentColor") : Color("CardBackgroundColor"))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color("BorderColor"), lineWidth: 1)
                )
                .foregroundColor(isSelected ? .white : Color("SubtitleColor"))
        }
    }
}

// 视图切换组件
struct ViewToggle: View {
    @Binding var isGridView: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                isGridView = false
            }) {
                Image(systemName: "list.bullet")
                    .font(.caption)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .foregroundColor(!isGridView ? .white : Color("SubtitleColor"))
                    .background(
                        Capsule()
                            .fill(!isGridView ? Color("AccentColor") : Color.clear)
                    )
            }
            
            Button(action: {
                isGridView = true
            }) {
                Image(systemName: "square.grid.2x2")
                    .font(.caption)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .foregroundColor(isGridView ? .white : Color("SubtitleColor"))
                    .background(
                        Capsule()
                            .fill(isGridView ? Color("AccentColor") : Color.clear)
                    )
            }
        }
        .background(
            Capsule()
                .fill(Color("CardBackgroundColor"))
        )
        .overlay(
            Capsule()
                .stroke(Color("BorderColor"), lineWidth: 1)
        )
    }
}

// 梦境列表视图
struct DreamList: View {
    let dreams: [Dream]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(dreams) { dream in
                    NavigationLink(destination: DreamDetailView(dream: dream)) {
                        DreamListItem(dream: dream)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 80) // 为底部标签栏留出空间
        }
    }
}

// 梦境网格视图
struct DreamGrid: View {
    let dreams: [Dream]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(dreams) { dream in
                    NavigationLink(destination: DreamDetailView(dream: dream)) {
                        DreamGridItem(dream: dream)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 80) // 为底部标签栏留出空间
        }
    }
}

// 梦境列表项组件
struct DreamListItem: View {
    let dream: Dream
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dream.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(dream.description)
                    .font(.caption)
                    .foregroundColor(Color("SubtitleColor"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(timeAgoText(for: dream.date) + " • 清晰度: " + clarityText(for: dream.clarity))
                    .font(.caption)
                    .foregroundColor(Color("MutedColor"))
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color("AccentColor"))
                    .frame(width: 36, height: 36)
                
                Text(dream.emotion)
                    .font(.title3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("CardBackgroundColor"))
        )
    }
    
    // 时间格式化辅助方法
    private func timeAgoText(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日"
            return formatter.string(from: date)
        }
    }
    
    // 清晰度格式化辅助方法
    private func clarityText(for clarity: Int) -> String {
        if clarity >= 7 {
            return "高"
        } else if clarity >= 4 {
            return "中"
        } else {
            return "低"
        }
    }
}

// 梦境网格项组件
struct DreamGridItem: View {
    let dream: Dream
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dream.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                Text(dream.emotion)
                    .font(.headline)
            }
            
            Divider()
                .background(Color("BorderColor"))
            
            Text(dream.description)
                .font(.caption)
                .foregroundColor(Color("SubtitleColor"))
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            HStack {
                Text(timeAgoText(for: dream.date))
                    .font(.caption)
                    .foregroundColor(Color("MutedColor"))
                
                Spacer()
                
                Text("清晰度: \(clarityText(for: dream.clarity))")
                    .font(.caption)
                    .foregroundColor(Color("MutedColor"))
            }
        }
        .padding()
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("CardBackgroundColor"))
        )
    }
    
    // 时间格式化辅助方法
    private func timeAgoText(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日"
            return formatter.string(from: date)
        }
    }
    
    // 清晰度格式化辅助方法
    private func clarityText(for clarity: Int) -> String {
        if clarity >= 7 {
            return "高"
        } else if clarity >= 4 {
            return "中"
        } else {
            return "低"
        }
    }
}

// 预览
struct DreamHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        DreamHistoryView()
            .preferredColorScheme(.dark)
    }
}
