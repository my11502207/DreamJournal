import SwiftUI
import SwiftData

struct DreamHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dream.date, order: .reverse) private var allDreams: [Dream]
    
    @State private var filterOption: FilterOption = .all
    @State private var searchText: String = ""
    @State private var isGridView: Bool = false
    @State private var selectedTags: [String] = []
    @State private var selectedEmotion: String = ""
    
    // 筛选选项
    enum FilterOption: String, CaseIterable {
        case all = "全部"
        case tags = "标签"
        case emotions = "情绪"
    }
    
    // 所有可用的标签
    var availableTags: [String] {
        var tags: Set<String> = []
        for dream in allDreams {
            for tag in dream.tags {
                tags.insert(tag)
            }
        }
        return Array(tags).sorted()
    }
    
    // 所有可用的情绪
    var availableEmotions: [String] {
        var emotions: Set<String> = []
        for dream in allDreams {
            emotions.insert(dream.emotion)
        }
        return Array(emotions).sorted()
    }
    
    // 筛选后的梦境
    var filteredDreams: [Dream] {
        var filtered = allDreams
        
        // 应用搜索文本筛选
        if !searchText.isEmpty {
            filtered = filtered.filter { dream in
                dream.title.localizedCaseInsensitiveContains(searchText) ||
                dream.description.localizedCaseInsensitiveContains(searchText) ||
                dream.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // 应用标签筛选
        if filterOption == .tags && !selectedTags.isEmpty {
            filtered = filtered.filter { dream in
                selectedTags.contains { tag in
                    dream.tags.contains(tag)
                }
            }
        }
        
        // 应用情绪筛选
        if filterOption == .emotions && !selectedEmotion.isEmpty {
            filtered = filtered.filter { $0.emotion == selectedEmotion }
        }
        
        return filtered
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
                    
                    // 标签筛选器（如果选择了标签筛选）
                    if filterOption == .tags && !availableTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(availableTags, id: \.self) { tag in
                                    TagFilterButton(
                                        tag: tag,
                                        isSelected: selectedTags.contains(tag),
                                        action: {
                                            if selectedTags.contains(tag) {
                                                selectedTags.removeAll { $0 == tag }
                                            } else {
                                                selectedTags.append(tag)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                    
                    // 情绪筛选器（如果选择了情绪筛选）
                    if filterOption == .emotions && !availableEmotions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Button(action: {
                                    selectedEmotion = ""
                                }) {
                                    Text("全部")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(selectedEmotion.isEmpty ? Color("AccentColor") : Color("CardBackgroundColor"))
                                        )
                                        .foregroundColor(selectedEmotion.isEmpty ? .white : Color("SubtitleColor"))
                                }
                                
                                ForEach(availableEmotions, id: \.self) { emotion in
                                    Button(action: {
                                        selectedEmotion = emotion
                                    }) {
                                        Text(emotion)
                                            .font(.title3)
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .fill(selectedEmotion == emotion ? Color("AccentColor") : Color("CardBackgroundColor"))
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                    
                    // 视图切换
                    HStack {
                        Text("\(filteredDreams.count)个梦境")
                            .font(.caption)
                            .foregroundColor(Color("SubtitleColor"))
                        
                        Spacer()
                        
                        ViewToggle(isGridView: $isGridView)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // 梦境列表
                    if filteredDreams.isEmpty {
                        VStack {
                            Spacer()
                            Image(systemName: "moon.stars")
                                .font(.largeTitle)
                                .foregroundColor(Color("SubtitleColor"))
                                .padding()
                            
                            Text("没有找到匹配的梦境")
                                .font(.headline)
                                .foregroundColor(Color("SubtitleColor"))
                            
                            if !searchText.isEmpty || filterOption != .all {
                                Text("尝试更改搜索条件")
                                    .font(.subheadline)
                                    .foregroundColor(Color("MutedColor"))
                                    .padding(.top, 4)
                            }
                            Spacer()
                        }
                        .padding(.top, 40)
                    } else {
                        if isGridView {
                            DreamGrid(dreams: filteredDreams)
                                .padding(.top, 12)
                        } else {
                            DreamList(dreams: filteredDreams)
                                .padding(.top, 12)
                        }
                    }
                }
            }
            .navigationTitle("梦境历史")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// 标签筛选按钮组件
struct TagFilterButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color("AccentColor") : Color("CardBackgroundColor"))
                )
                .foregroundColor(isSelected ? .white : Color("SubtitleColor"))
        }
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
