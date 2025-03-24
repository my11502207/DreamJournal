import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dream.date, order: .reverse) private var dreams: [Dream]
    @State private var showAddDreamSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading) {
                    // 统计卡片
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("梦境统计")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("记录天数: \(recordedDaysCount())")
                                .font(.subheadline)
                                .foregroundColor(Color("SubtitleColor"))
                            
                            Text("常见情绪: \(commonEmotions())")
                                .font(.subheadline)
                                .foregroundColor(Color("SubtitleColor"))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("CardBackgroundColor"))
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                    )
                    .padding(.bottom)
                    
                    // 最近梦境标题
                    Text("最近梦境")
                        .font(.subheadline)
                        .foregroundColor(Color("SubtitleColor"))
                        .padding(.leading, 4)
                    
                    // 梦境列表
                    if dreams.isEmpty {
                        VStack {
                            Spacer()
                            Text("还没有记录梦境")
                                .font(.headline)
                                .foregroundColor(Color("SubtitleColor"))
                            Text("点击下方按钮开始记录您的第一个梦境")
                                .font(.subheadline)
                                .foregroundColor(Color("MutedColor"))
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(dreams.prefix(5)) { dream in
                                    NavigationLink(destination: DreamDetailView(dream: dream)) {
                                        DreamCard(dream: dream)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                
                // 添加按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showAddDreamSheet = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color("AccentColor"))
                                    .frame(width: 56, height: 56)
                                    .shadow(color: Color("AccentColor").opacity(0.4), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .padding(.trailing, 8)
                    }
                    .padding(.bottom, 70)
                }
            }
            .navigationTitle("梦境记录")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileButton()
                }
            }
            .sheet(isPresented: $showAddDreamSheet) {
                AddDreamView()
            }
            .onAppear(perform: checkAndCreateSampleDreams)
        }
    }
    
    // 如果没有数据，创建示例数据
    private func checkAndCreateSampleDreams() {
        if dreams.isEmpty {
            let sampleDreams = [
                Dream(title: "飞行梦", dreamContent:  "我梦见自己在城市上空飞行，感觉非常自由...", date: Date(), clarity: 8, emotion: "😮", tags: ["飞行", "城市", "自由"]),
                Dream(title: "迷宫梦", dreamContent: "在一个复杂的迷宫中寻找出口，墙壁不断变化...", date: Date().addingTimeInterval(-86400), clarity: 6, emotion: "😨", tags: ["迷宫", "寻找", "恐惧"]),
                Dream(title: "海边漫步", dreamContent: "我梦见自己在一个安静的海滩上漫步，海浪声非常清晰...", date: Date().addingTimeInterval(-3*86400), clarity: 9, emotion: "😌", tags: ["海滩", "平静", "水"])
            ]
            
            for dream in sampleDreams {
                modelContext.insert(dream)
            }
        }
    }
    
    // 计算记录天数
    private func recordedDaysCount() -> Int {
        let uniqueDates = Set(dreams.map { Calendar.current.startOfDay(for: $0.date) })
        return uniqueDates.count
    }
    
    // 找出最常见的情绪
    private func commonEmotions() -> String {
        if dreams.isEmpty {
            return "无数据"
        }
        
        var emotionCounts: [String: Int] = [:]
        for dream in dreams {
            emotionCounts[dream.emotion, default: 0] += 1
        }
        
        // 排序并取前两个常见情绪
        let topEmotions = emotionCounts.sorted { $0.value > $1.value }.prefix(2)
        return topEmotions.map { $0.key }.joined(separator: ", ")
    }
}

// 梦境卡片组件
struct DreamCard: View {
    let dream: Dream
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dream.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(dream.description)
                    .font(.caption)
                    .foregroundColor(Color("SubtitleColor"))
                    .lineLimit(2)
                
                Text(timeAgoText(for: dream.date) + " • 清晰度: " + clarityText(for: dream.clarity))
                    .font(.caption)
                    .foregroundColor(Color("MutedColor"))
                    .padding(.top, 2)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color("AccentColor").opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Text(dream.emotion)
                    .font(.title3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("CardBackgroundColor"))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
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

// 个人资料按钮
struct ProfileButton: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("CardBackgroundColor"))
                .frame(width: 36, height: 36)
            
            Text("JL")
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}
