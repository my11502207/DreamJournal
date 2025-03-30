import SwiftUI

struct DetailedDreamAnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var dream: Dream
    @State private var analysisResult: DreamAnalysisService.DreamAnalysisResult?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isAnalysisSaved = false
    @Environment(\.dismiss) private var dismiss
    
    private let analysisService = DreamAnalysisService()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    LoadingView()
                } else if let errorMsg = errorMessage {
                    ErrorView(message: errorMsg) {
                        performAnalysis()
                    }
                } else if let result = analysisResult, let analysis = result.analysis {
                    AnalysisContentView(result: result, isAnalysisSaved: $isAnalysisSaved) {
                        // 保存分析结果
                        saveAnalysisResult(result)
                    }
                } else if let result = analysisResult, result.errorMessage != nil {
                    ErrorView(message: result.errorMessage ?? "解析失败") {
                        performAnalysis()
                    }
                } else if dream.analysisResult != nil {
                    // 显示已保存的分析结果
                    SavedAnalysisView(dream: dream)
                } else {
                    // 初始状态，显示"分析中"的视图
                    VStack {
                        Spacer()
                        
                        Image(systemName: "brain")
                            .font(.system(size: 60))
                            .foregroundColor(Color("AccentColor"))
                            .padding()
                        
                        Text("梦境深度解析")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        
                        Text("我们将通过人工智能分析您梦境中的象征物并提供更深入的解读")
                            .font(.subheadline)
                            .foregroundColor(Color("SubtitleColor"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 24)
                        
                        Button(action: performAnalysis) {
                            HStack {
                                Image(systemName: "sparkles.rectangle.stack")
                                    .font(.headline)
                                
                                Text("开始深度解析")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("AccentColor"))
                                    .shadow(color: Color("AccentColor").opacity(0.3), radius: 5, x: 0, y: 3)
                            )
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("深度解析")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // 检查是否已有分析结果
                if dream.analysisResult == nil {
                    // 可选：自动开始分析
                    // performAnalysis()
                }
            }
        }
    }
    
    // 保存分析结果到梦境对象中
    private func saveAnalysisResult(_ result: DreamAnalysisService.DreamAnalysisResult) {
        dream.analysisResult = result.analysis
        dream.analysisSymbols = result.symbols
        dream.analysisSentiment = result.sentiment_score
        dream.analysisTheme = result.theme
        dream.analysisDate = Date()
        
        // SwiftData会自动保存更改
        isAnalysisSaved = true
    }
    
    // 执行梦境分析
    private func performAnalysis() {
        isLoading = true
        errorMessage = nil
        
        analysisService.analyzeDream(date: dream.date, content: dream.dreamContent) { result in
            isLoading = false
            
            switch result {
            case .success(let result):
                if result.analysis != nil {
                    self.analysisResult = result
                    // 自动保存分析结果
                    self.saveAnalysisResult(result)
                } else {
                    // API返回了结果但没有分析内容
                    errorMessage = result.errorMessage ?? "无法解析此梦境，请稍后再试"
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

// 已保存的分析视图
struct SavedAnalysisView: View {
    let dream: Dream
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 分析时间
                if let analysisDate = dream.analysisDate {
                    HStack {
                        Spacer()
                        Text("分析完成于 \(formattedDate(analysisDate))")
                            .font(.caption)
                            .foregroundColor(Color("SubtitleColor"))
                    }
                    .padding(.horizontal)
                }
                
                // 解释部分
                VStack(alignment: .leading, spacing: 10) {
                    Text("梦境解读")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(dream.analysisResult ?? "")
                        .font(.body)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("CardBackgroundColor"))
                        )
                }
                .padding(.horizontal)
                
                // 象征物部分
                if let symbols = dream.analysisSymbols, !symbols.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("梦境象征物")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                            ForEach(symbols, id: \.self) { symbol in
                                SymbolTag(symbol: symbol)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 情感分数
                if let sentimentScore = dream.analysisSentiment {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("情感倾向")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        SentimentScoreView(score: sentimentScore)
                    }
                    .padding(.horizontal)
                }
                
                // 主题
                if let theme = dream.analysisTheme, !theme.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("梦境主题")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(theme)
                            .font(.body)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("CardBackgroundColor"))
                            )
                    }
                    .padding(.horizontal)
                }
                
                // 提示信息
                VStack(alignment: .leading, spacing: 10) {
                    Text("记录梦境的好处")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("研究表明，定期记录和解析梦境有助于提高自我认知、增强创造力，甚至可能改善心理健康。通过理解您的梦境象征，您可以获得对内心世界的独特洞察。")
                        .font(.subheadline)
                        .foregroundColor(Color("SubtitleColor"))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("CardBackgroundColor"))
                        )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    // 格式化日期
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// 解析内容视图 - 添加保存按钮
struct AnalysisContentView: View {
    let result: DreamAnalysisService.DreamAnalysisResult
    @Binding var isAnalysisSaved: Bool
    let saveAction: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 保存按钮
                if !isAnalysisSaved {
                    Button(action: saveAction) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .font(.headline)
                            
                            Text("保存分析结果")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("AccentColor"))
                        )
                    }
                    .padding(.horizontal)
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("分析结果已保存")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("CardBackgroundColor"))
                    )
                    .padding(.horizontal)
                }
                
                // 解释部分
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("梦境解读")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if let timestamp = result.formattedTimestamp {
                            Text(timestamp)
                                .font(.caption)
                                .foregroundColor(Color("SubtitleColor"))
                        }
                    }
                    
                    Text(result.analysis ?? "")
                        .font(.body)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("CardBackgroundColor"))
                        )
                }
                .padding(.horizontal)
                
                // 象征物部分
                if let symbols = result.symbols, !symbols.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("梦境象征物")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                            ForEach(symbols, id: \.self) { symbol in
                                SymbolTag(symbol: symbol)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 情感分数
                if let sentimentScore = result.sentiment_score {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("情感倾向")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        SentimentScoreView(score: sentimentScore)
                    }
                    .padding(.horizontal)
                }
                
                // 主题
                if let theme = result.theme, !theme.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("梦境主题")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(theme)
                            .font(.body)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("CardBackgroundColor"))
                            )
                    }
                    .padding(.horizontal)
                }
                
                // 提示信息
                VStack(alignment: .leading, spacing: 10) {
                    Text("记录梦境的好处")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("研究表明，定期记录和解析梦境有助于提高自我认知、增强创造力，甚至可能改善心理健康。通过理解您的梦境象征，您可以获得对内心世界的独特洞察。")
                        .font(.subheadline)
                        .foregroundColor(Color("SubtitleColor"))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("CardBackgroundColor"))
                        )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// 象征物标签
struct SymbolTag: View {
    let symbol: String
    
    var body: some View {
        Text(symbol)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("AccentColor").opacity(0.7))
            )
            .fixedSize(horizontal: true, vertical: false)
    }
}

// 情感分数视图
struct SentimentScoreView: View {
    let score: Double
    
    // 转换分数为文本描述
    var sentimentDescription: String {
        if score >= 0.5 {
            return "积极"
        } else if score > 0 {
            return "稍积极"
        } else if score == 0 {
            return "中性"
        } else if score > -0.5 {
            return "稍消极"
        } else {
            return "消极"
        }
    }
    
    // 根据分数获取颜色
    var sentimentColor: Color {
        if score >= 0.5 {
            return .green
        } else if score > 0 {
            return .mint
        } else if score == 0 {
            return .gray
        } else if score > -0.5 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 情感条
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color("CardBackgroundColor").opacity(0.5))
                    .frame(height: 10)
                    .cornerRadius(5)
                
                Rectangle()
                    .fill(sentimentColor)
                    .frame(width: max(10, CGFloat(score + 1) * 150), height: 10)
                    .cornerRadius(5)
                
                Circle()
                    .fill(sentimentColor)
                    .frame(width: 18, height: 18)
                    .offset(x: CGFloat(score + 1) * 150 - 9)
            }
            .frame(width: 300)
            .overlay(
                HStack {
                    Text("消极")
                        .font(.caption)
                        .foregroundColor(Color("SubtitleColor"))
                    
                    Spacer()
                    
                    Text("积极")
                        .font(.caption)
                        .foregroundColor(Color("SubtitleColor"))
                }
                .padding(.horizontal, 4)
                .padding(.top, 14)
            )
            
            Text("情感倾向: \(sentimentDescription)")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(sentimentColor.opacity(0.3))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("CardBackgroundColor"))
        )
    }
}

struct DetailedDreamAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedDreamAnalysisView(dream: Dream(
            title: "飞行梦",
            dreamContent: "我梦见自己在城市上空飞行，感觉非常自由...",
            date: Date(),
            clarity: 8,
            emotion: "😮",
            tags: ["飞行", "城市", "自由"]
        ))
        .preferredColorScheme(.dark)
    }
}

// 加载中视图
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("AccentColor")))
                .scaleEffect(2)
            
            Text("正在深度解析您的梦境...")
                .font(.headline)
                .foregroundColor(Color("SubtitleColor"))
            
            Text("这可能需要一些时间，请耐心等待")
                .font(.subheadline)
                .foregroundColor(Color("MutedColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// 错误视图
struct ErrorView: View {
    let message: String
    var retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(Color("SubtitleColor"))
            
            Text("解析出错")
                .font(.title3)
                .foregroundColor(.white)
            
            Text(message)
                .font(.body)
                .foregroundColor(Color("SubtitleColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: retryAction) {
                Text("重新尝试")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("AccentColor"))
                    )
            }
            .padding(.top)
        }
    }
}

