import SwiftUI
import SwiftData

struct FavoriteDreamsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Dream> { $0.isFavorite == true }, sort: \Dream.date, order: .reverse) private var favoriteDreams: [Dream]
    @State private var isGridView: Bool = false
    @State private var searchText: String = ""
    
    var filteredDreams: [Dream] {
        if searchText.isEmpty {
            return favoriteDreams
        } else {
            return favoriteDreams.filter { dream in
                dream.title.localizedCaseInsensitiveContains(searchText) ||
                dream.dreamContent.localizedCaseInsensitiveContains(searchText) ||
                dream.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // 视图切换
                HStack {
                    Text("\(filteredDreams.count)个收藏梦境")
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
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(Color("SubtitleColor"))
                            .padding()
                        
                        Text(searchText.isEmpty ? "暂无收藏梦境" : "没有找到匹配的收藏梦境")
                            .font(.headline)
                            .foregroundColor(Color("SubtitleColor"))
                        
                        if searchText.isEmpty {
                            Text("在梦境详情页点击心形图标收藏梦境")
                                .font(.subheadline)
                                .foregroundColor(Color("MutedColor"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 4)
                        } else {
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
                        FavoriteDreamGrid(dreams: filteredDreams)
                            .padding(.top, 12)
                    } else {
                        FavoriteDreamList(dreams: filteredDreams)
                            .padding(.top, 12)
                    }
                }
            }
        }
        .navigationTitle("收藏梦境")
        .navigationBarTitleDisplayMode(.large)
    }
}

// 收藏梦境列表视图
struct FavoriteDreamList: View {
    let dreams: [Dream]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(dreams) { dream in
                    NavigationLink(destination: DreamDetailView(dream: dream)) {
                        FavoriteDreamCard(dream: dream)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

// 收藏梦境网格视图
struct FavoriteDreamGrid: View {
    let dreams: [Dream]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(dreams) { dream in
                    NavigationLink(destination: DreamDetailView(dream: dream)) {
                        FavoriteDreamGridItem(dream: dream)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

// 收藏梦境卡片组件
struct FavoriteDreamCard: View {
    let dream: Dream
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(dream.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Text(dream.dreamContent)
                    .font(.caption)
                    .foregroundColor(Color("SubtitleColor"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(timeAgoText(for: dream.date))
                        .font(.caption)
                        .foregroundColor(Color("MutedColor"))
                    
                    if !dream.tags.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(Color("MutedColor"))
                        
                        Text(dream.tags.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(Color("MutedColor"))
                            .lineLimit(1)
                    }
                }
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
}

// 收藏梦境网格项组件
struct FavoriteDreamGridItem: View {
    let dream: Dream
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dream.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundColor(.red)
                
                Text(dream.emotion)
                    .font(.headline)
            }
            
            Divider()
                .background(Color("BorderColor"))
            
            Text(dream.dreamContent)
                .font(.caption)
                .foregroundColor(Color("SubtitleColor"))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            HStack {
                Text(timeAgoText(for: dream.date))
                    .font(.caption)
                    .foregroundColor(Color("MutedColor"))
                
                Spacer()
                
                if !dream.tags.isEmpty {
                    Text(dream.tags.first ?? "")
                        .font(.caption)
                        .foregroundColor(Color("MutedColor"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color("CardBackgroundColor").opacity(0.3))
                        )
                }
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
}

// 搜索栏组件复用
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

