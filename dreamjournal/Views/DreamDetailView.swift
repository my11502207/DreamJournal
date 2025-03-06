import SwiftUI

struct DreamDetailView: View {
    let dream: Dream
    @State private var showEditSheet: Bool = false
    
    // 模拟一些相似梦境
    let similarDreams = [
        "悬浮梦", "超能力梦", "飞行体验"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 梦境标题卡片
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dream.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(formattedDate(dream.date) + " • 清晰度: " + clarityText(for: dream.clarity))
                            .font(.subheadline)
                            .foregroundColor(Color("SubtitleColor"))
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
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("CardBackgroundColor"))
                )
                
//                // 标签部分
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("标签:")
//                        .font(.subheadline)
//                        .foregroundColor(Color("SubtitleColor"))
//                    
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 8) {
//                            ForEach(dream.tags, id: \.self) { tag in
//                                TagView(tag: tag)
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal)
                
                // 梦境描述
                VStack(alignment: .leading, spacing: 8) {
                    Text("梦境描述:")
                        .font(.subheadline)
                        .foregroundColor(Color("SubtitleColor"))
                    
                    Text(dream.description)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("CardBackgroundColor"))
                        )
                }
                .padding(.horizontal)
                
                // 梦境分析
                VStack(alignment: .leading, spacing: 8) {
                    Text("梦境分析:")
                        .font(.subheadline)
                        .foregroundColor(Color("SubtitleColor"))
                    
                    Text(dreamAnalysis())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("CardBackgroundColor"))
                        )
                }
                .padding(.horizontal)
                
                // 相似梦境
                VStack(alignment: .leading, spacing: 8) {
                    Text("相似梦境:")
                        .font(.subheadline)
                        .foregroundColor(Color("SubtitleColor"))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(similarDreams, id: \.self) { dreamTitle in
                                Button(action: {
                                    // 导航到相似梦境详情
                                }) {
                                    Text(dreamTitle)
                                        .font(.subheadline)
                                        .foregroundColor(Color("SubtitleColor"))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color("CardBackgroundColor"))
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
        .navigationTitle("梦境详情")
        .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(Color("SubtitleColor"))
                                .padding(8)
                                .background(Circle().fill(Color("CardBackgroundColor")))
                        }
                    }
                }
                .sheet(isPresented: $showEditSheet) {
                    EditDreamView(dream: dream)
                }
    }
    
    // 格式化日期
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    // 清晰度文本
    private func clarityText(for clarity: Int) -> String {
        if clarity >= 7 {
            return "高"
        } else if clarity >= 4 {
            return "中"
        } else {
            return "低"
        }
    }
    
    // 根据梦境内容生成分析
    private func dreamAnalysis() -> String {
        if dream.title.contains("飞行") {
            return "飞行梦通常象征自由感和控制欲望。你的梦境表明你可能正在寻求生活中的更多自由或突破限制。城市环境可能反映了你对社会结构的看法，而你能够在其中自由移动，表明了你有能力超越常规思维和限制。"
        } else if dream.title.contains("迷宫") {
            return "迷宫梦通常与寻找方向、迷失和做出决定有关。你的梦可能反映了你当前生活中面临的复杂选择或不确定性。墙壁不断变化的元素可能代表了情况的不稳定性或难以把握的问题。"
        } else {
            return "这种梦境通常表明你的潜意识正在处理与\(dream.tags.first ?? "特定主题")相关的情绪和经历。你的梦中情绪(\(dream.emotion))可能反映了你对这一主题的真实感受。考虑这些元素如何与你当前的生活环境产生共鸣。"
        }
    }
}




