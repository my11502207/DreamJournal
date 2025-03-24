import SwiftUI
import Charts
import SwiftData

// Data models for dream analysis
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

struct DreamAnalysisView: View {
    @Query(sort: \Dream.date, order: .reverse) private var allDreams: [Dream]
    @State private var selectedTimeRange: TimeRange = .month
    
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
            return allDreams.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return allDreams.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            return allDreams.filter { $0.date >= yearAgo }
        case .all:
            return allDreams
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
                
                if allDreams.isEmpty {
                    // 空状态视图
                    VStack(spacing: 16) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 60))
                            .foregroundColor(Color("SubtitleColor"))
                            .padding()
                        
                        Text("还没有足够的数据")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text("记录更多梦境后，这里将显示您的梦境分析数据")
                            .font(.body)
                            .foregroundColor(Color("SubtitleColor"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
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
            }
            .navigationTitle("梦境分析")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// 其他组件定义...
