import SwiftUI
import Speech

struct AddDreamView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var dreamTitle: String = ""
    @State private var dreamDescription: String = ""
    @State private var selectedEmotion: String = "😌"
    @State private var clarity: Double = 5.0
    @State private var selectedTags: [String] = []
    @State private var newTag: String = ""
    @State private var isRecording: Bool = false
    @State private var recordingText: String = ""
    @State private var date: Date = Date()
    
    let emotions = ["😊", "😌", "😮", "😨", "🤔", "😢"]
    let availableTags = ["海滩", "飞行", "迷宫", "自由", "恐惧", "水", "城市", "平静"]
    
    // 语音识别相关
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // 日期选择器
                        HStack {
                            Text("日期:")
                                .foregroundColor(Color("SubtitleColor"))
                            
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                                .foregroundColor(.white)
                        }
                        
                        // 标题输入
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标题:")
                                .foregroundColor(Color("SubtitleColor"))
                            
                            TextField("为你的梦境取个标题", text: $dreamTitle)
                                .padding()
                                .background(Color("CardBackgroundColor"))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        // 情绪选择器
                        VStack(alignment: .leading, spacing: 8) {
                            Text("情绪:")
                                .foregroundColor(Color("SubtitleColor"))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(emotions, id: \.self) { emotion in
                                        EmotionButton(
                                            emotion: emotion,
                                            isSelected: selectedEmotion == emotion,
                                            action: { selectedEmotion = emotion }
                                        )
                                    }
                                    
                                    // 添加自定义情绪按钮
                                    Button(action: {
                                        // 显示自定义情绪选择器
                                    }) {
                                        ZStack {
                                            Circle()
                                                .stroke(Color("BorderColor"), lineWidth: 1)
                                                .background(Circle().fill(Color("CardBackgroundColor")))
                                                .frame(width: 36, height: 36)
                                            
                                            Text("+")
                                                .font(.title3)
                                                .foregroundColor(Color("SubtitleColor"))
                                        }
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        
                        // 清晰度滑块
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("清晰度:")
                                    .foregroundColor(Color("SubtitleColor"))
                                
                                Spacer()
                                
                                Text("\(Int(clarity))")
                                    .foregroundColor(.white)
                            }
                            
                            Slider(value: $clarity, in: 1...10, step: 1)
                                .accentColor(Color("AccentColor"))
                        }
                        
                        // 梦境描述
                        VStack(alignment: .leading, spacing: 8) {
                            Text("梦境描述:")
                                .foregroundColor(Color("SubtitleColor"))
                            
                            TextEditor(text: $dreamDescription)
                                .frame(minHeight: 150)
                                .padding(4)
                                .background(Color("CardBackgroundColor"))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        // 语音录入按钮
                        VStack {
                            Button(action: {
                                if isRecording {
                                    stopRecording()
                                } else {
                                    startRecording()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(isRecording ? Color.red : Color("AccentColor"))
                                        .frame(width: 48, height: 48)
                                        .shadow(color: (isRecording ? Color.red : Color("AccentColor")).opacity(0.4), radius: 4, x: 0, y: 2)
                                    
                                    if isRecording {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white)
                                            .frame(width: 16, height: 16)
                                    } else {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 18, height: 18)
                                    }
                                }
                            }
                            
                            Text(isRecording ? "点击停止录音" : "点击开始语音记录")
                                .font(.caption)
                                .foregroundColor(Color("SubtitleColor"))
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        
                        // 标签选择
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标签:")
                                .foregroundColor(Color("SubtitleColor"))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(selectedTags, id: \.self) { tag in
                                        TagView(tag: tag, isSelected: true) {
                                            selectedTags.removeAll { $0 == tag }
                                        }
                                    }
                                    
                                    // 添加标签按钮
                                    Button(action: {
                                        showTagPicker()
                                    }) {
                                        ZStack {
                                            Capsule()
                                                .stroke(Color("BorderColor"), lineWidth: 1)
                                                .frame(width: 36, height: 26)
                                            
                                            Text("+")
                                                .font(.caption)
                                                .foregroundColor(Color("SubtitleColor"))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("记录新梦境")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveDream) {
                        Text("保存")
                            .fontWeight(.medium)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
            .onAppear {
                requestSpeechRecognitionAuthorization()
            }
        }
    }
    
    // 保存梦境
    private func saveDream() {
        // 处理输入数据并保存梦境
        let newDream = Dream(
            id: UUID().uuidString,
            title: dreamTitle.isEmpty ? "未命名梦境" : dreamTitle,
            description: dreamDescription,
            date: date,
            clarity: Int(clarity),
            emotion: selectedEmotion,
            tags: selectedTags
        )
        
        // 实际项目中，这里会将newDream保存到数据存储中
        print("保存梦境:", newDream)
        
        // 返回上一页
        presentationMode.wrappedValue.dismiss()
    }
    
    // 显示标签选择器
    private func showTagPicker() {
        // 实际应用中这里应该显示一个标签选择的sheet或者弹窗
        // 简化示例，我们假设选择了一个新标签
        if !availableTags.isEmpty {
            let availableTag = availableTags.first(where: { !selectedTags.contains($0) })
            if let tag = availableTag {
                selectedTags.append(tag)
            }
        }
    }
    
    // 请求语音识别权限
    private func requestSpeechRecognitionAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            // 处理授权结果
        }
    }
    
    // 开始录音
    private func startRecording() {
        // 实际应用中这里需要实现开始录音的逻辑
        isRecording = true
    }
    
    // 停止录音
    private func stopRecording() {
        // 实际应用中这里需要实现停止录音并处理识别结果的逻辑
        isRecording = false
        
        // 模拟更新描述文本
        if dreamDescription.isEmpty {
            dreamDescription = "我梦见自己在一个安静的海滩上漫步，海浪声非常清晰。天空是紫色的，有两轮明月。我感到非常平静和放松..."
        } else {
            dreamDescription += "\n\n接着，我走进了大海，但奇怪的是我能在水面上行走..."
        }
    }
}

// 情绪按钮组件
struct EmotionButton: View {
    let emotion: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color("AccentColor") : Color("CardBackgroundColor"))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.clear : Color("BorderColor"), lineWidth: 1)
                    )
                
                Text(emotion)
                    .font(.title3)
            }
        }
    }
}
