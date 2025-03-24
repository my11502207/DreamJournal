import SwiftUI
import Charts

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
                .frame(height: CGFloat(max(emotionData.count * 40, 100)))
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
            
            if tagData.isEmpty {
                Text("还没有足够的标签数据")
                    .font(.caption)
                    .foregroundColor(Color("SubtitleColor"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if #available(iOS 16.0, *) {
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
