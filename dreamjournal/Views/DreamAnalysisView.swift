import SwiftUI
import Charts

struct DreamAnalysisView: View {
    @State private var selectedTimeRange: TimeRange = .month
    @State private var dreams: [Dream] = [
        Dream(id: "1", title: "飞行梦", description: "我梦见自己在城市上空飞行，感觉非常自由...", date: Date(), clarity: 8, emotion: "😮", tags: ["飞行", "城市", "自由"]),
        Dream(id: "2", title: "迷宫梦", description: "在一个复杂的迷宫中寻找出口，墙壁不断变化...", date: Date().addingTimeInterval(-86400), clarity: 6, emotion: "😨", tags: ["迷宫", "寻找", "恐惧"]),
        Dream(id: "3", title: "海边漫步", description: "我梦见自己在一个安静的海滩上漫步，海浪声非常清晰...", date: Date().addingTimeInterval(-3*86400), clarity: 9, emotion: "😌", tags: ["海滩", "平静", "水"]),
        Dream(id: "4", title: "古老图书馆", description: "在一个巨大的古代图书馆中探索，书架高耸入云...", date: Date().addingTimeInterval(-7*86400), clarity: 3, emotion: "🤔", tags: ["图书馆", "探索", "知识"]),
        Dream(id: "5", title: "飞船旅行", description: "乘坐宇宙飞船穿梭在星系之间...", date: Date().addingTimeInterval(-10*86400), clarity: 7, emotion: "😮", tags: ["太空", "飞行", "探索"]),
        Dream(id: "6", title: "与动物对话", description: "能够和各种动物交流，了解它们的想法...", date: Date().addingTimeInterval(-15*86400), clarity: 5, emotion: "😊", tags: ["动物", "交流", "奇幻"]),
        Dream(id: "7", title: "水下城市", description: "探索一座完全位于海底的巨大城市...", date: Date().addingTimeInterval(-20*86400), clarity: 8, emotion: "😮", tags: ["水", "城市", "探索"])
    ]
    
    // 时间范围选项
    enum TimeRange: String, CaseIterable {
        case week = "周"
        case month = "月"
        case year = "年"
        case all = "全部"
    }
    
    // 根据时间范围过滤梦境
    var filteredDreams: [Dream] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return dreams.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return dreams.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            return dreams.filter { $0.date >= yearAgo }
        case .all:
            return dreams
        }
    }
    
    // 计算情绪频率
    var emotionFrequency: [EmotionData] {
        var emotionCounts: [String: Int] = [:]
        
        for dream in filteredDreams {
            emotionCounts[dream.emotion, default: 0] += 1
        }
        
        return emotionCounts.map { EmotionData(emotion: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    // 计算标签频率
    var tagFrequency: [TagData] {
        var tagCounts: [String: Int] = [:]
        
        for dream in filteredDreams {
            for tag in dream.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        
        return tagCounts.map { TagData(tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(8)
            .map { $0 }
    }
    
    // 计算清晰度随时间的变化
    var clarityOverTime: [ClarityData] {
        let sortedDreams = filteredDreams.sorted { $0.date < $1.date }
        
        return sortedDreams.map { dream in
            ClarityData(date: dream.date, clarity: dream.clarity)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 时间范围选择器
                        TimeRangeSelector(selectedRange: $selectedTimeRange)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // 统计摘要
                        StatisticsSummary(dreams: filteredDreams)
                            .padding(.horizontal)
                        
                        // 情绪分布图
                        EmotionDistributionChart(emotionData: emotionFrequency)
                            .padding(.horizontal)
                        
                        // 清晰度随时间变化图
                        ClarityTrendChart(clarityData: clarityOverTime)
                            .padding(.horizontal)
                        
                        // 常见标签
                        TagsFrequencyChart(tagData: Array(tagFrequency))
                            .padding(.horizontal)
                        
                        // 梦境洞察
                        DreamInsightsCard()
                            .padding(.horizontal)
                        
                        // 为底部标签栏留出空间
                        Spacer()
                            .frame(height: 80)
                    }
                    .padding(.vertical)
                }
                
            }
            .navigationTitle("梦境分析")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}



// 统计摘要组件
struct StatisticsSummary: View {
    let dreams: [Dream]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("统计摘要")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 4)
            
            HStack {
                StatCard(title: "记录总数", value: "\(dreams.count)")
                StatCard(title: "平均清晰度", value: String(format: "%.1f", averageClarity()))
                StatCard(title: "常见情绪", value: mostCommonEmotion())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("CardBackgroundColor"))
        )
    }
    
    // 计算平均清晰度
    private func averageClarity() -> Double {
        if dreams.isEmpty {
            return 0
        }
        let total = dreams.reduce(0) { $0 + $1.clarity }
        return Double(total) / Double(dreams.count)
    }
    
    // 找出最常见的情绪
    private func mostCommonEmotion() -> String {
        if dreams.isEmpty {
            return "无数据"
        }
        
        var emotionCounts: [String: Int] = [:]
        for dream in dreams {
            emotionCounts[dream.emotion, default: 0] += 1
        }
        
        let mostCommon = emotionCounts.max { $0.value < $1.value }
        return mostCommon?.key ?? "无数据"
    }
}

// 统计卡片组件
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color("SubtitleColor"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("CardBackgroundColor").opacity(0.3))
        )
    }
}

// 情绪分布图组件
struct EmotionDistributionChart: View {
    let emotionData: [EmotionData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("情绪分布")
                .font(.headline)
                .foregroundColor(.white)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(emotionData) { item in
                        BarMark(
                            x: .value("频率", item.count),
                            y: .value("情绪", item.emotion)
                        )
                        .foregroundStyle(Color("AccentColor"))
                        .cornerRadius(4)
                    }
                }
                .frame(height: CGFloat(emotionData.count * 40))
                .padding(.top, 8)
            } else {
                // 为iOS 16以下版本提供备用视图
                VStack(spacing: 12) {
                    ForEach(emotionData) { item in
                        HStack {
                            Text(item.emotion)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 40)
                            
                            GeometryReader { geometry in
                                let maxWidth = geometry.size.width
                                let barWidth = min(CGFloat(item.count) / CGFloat(emotionData.first?.count ?? 1) * maxWidth, maxWidth)
                                
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color("CardBackgroundColor").opacity(0.3))
                                        .frame(width: maxWidth, height: 24)
                                        .cornerRadius(4)
                                    
                                    Rectangle()
                                        .fill(Color("AccentColor"))
                                        .frame(width: barWidth, height: 24)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 24)
                            
                            Text("\(item.count)")
                                .font(.caption)
                                .foregroundColor(Color("SubtitleColor"))
                                .frame(width: 30)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("CardBackgroundColor"))
        )
    }
}

// 清晰度趋势图组件
struct ClarityTrendChart: View {
    let clarityData: [ClarityData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("清晰度趋势")
                .font(.headline)
                .foregroundColor(.white)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(clarityData) { item in
                        LineMark(
                            x: .value("日期", item.date),
                            y: .value("清晰度", item.clarity)
                        )
                        .foregroundStyle(Color("AccentColor"))
                        .symbol {
                            Circle()
                                .fill(Color("AccentColor"))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .frame(height: 200)
                .padding(.top, 8)
            } else {
                // 为iOS 16以下版本提供备用视图
                Text("清晰度数据可视化（需要iOS 16或更高版本）")
                    .font(.caption)
                    .foregroundColor(Color("SubtitleColor"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("CardBackgroundColor"))
        )
    }
}

// 标签频率图组件
struct TagsFrequencyChart: View {
    let tagData: [TagData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("常见标签")
                .font(.headline)
                .foregroundColor(.white)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(tagData) { item in
                        BarMark(
                            x: .value("标签", item.tag),
                            y: .value("频率", item.count)
                        )
                        .foregroundStyle(Color("AccentColor"))
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .padding(.top, 8)
            } else {
                // 为iOS 16以下版本提供备用视图
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(tagData) { item in
                        HStack {
                            Text(item.tag)
                                .font(.caption)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(item.count)")
                                .font(.caption)
                                .foregroundColor(Color("SubtitleColor"))
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("CardBackgroundColor").opacity(0.3))
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("CardBackgroundColor"))
        )
    }
}

// 梦境洞察卡片组件
struct DreamInsightsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("梦境洞察")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 16) {
                InsightItem(
                    title: "探索主题",
                    description: "你的梦境中经常出现探索元素，这可能反映了你对新体验的渴望和好奇心。"
                )
                
                InsightItem(
                    title: "情绪模式",
                    description: "惊奇和好奇是你梦境中的主要情绪，表明你的潜意识思维趋向于积极的探索状态。"
                )
                
                InsightItem(
                    title: "清晰度提升",
                    description: "你的梦境清晰度正在提高，这可能表明你的记忆能力或醒前意识在增强。"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("CardBackgroundColor"))
        )
    }
}

// 洞察项目组件
struct InsightItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Text(description)
                .font(.caption)
                .foregroundColor(Color("SubtitleColor"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// 数据模型结构
struct EmotionData: Identifiable {
    let id = UUID()
    let emotion: String
    let count: Int
}

struct TagData: Identifiable {
    let id = UUID()
    let tag: String
    let count: Int
}

struct ClarityData: Identifiable {
    let id = UUID()
    let date: Date
    let clarity: Int
}



