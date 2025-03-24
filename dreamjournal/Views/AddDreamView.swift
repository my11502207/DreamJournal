import SwiftUI
import Speech
import AVFoundation
import SwiftData

struct AddDreamView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // 基本梦境属性
    @State private var dreamTitle: String = ""
    @State private var dreamDescription: String = ""
    @State private var selectedEmotion: String = "😌"
    @State private var clarity: Double = 5.0
    @State private var selectedTags: [String] = []
    @State private var date: Date = Date()
    @State private var isLucidDream: Bool = false
    @State private var isFavorite: Bool = false
    
    // 语音识别相关
    @State private var isRecording: Bool = false
    @State private var recordingText: String = ""
    @State private var speechRecognitionEnabled = false
    @State private var microphoneEnabled = false
    @State private var showAuthorizationAlert = false
    @State private var authorizationAlertMessage = ""
    
    // 标签选择相关
    @State private var showingTagSheet = false
    
    // 情绪选择相关
    @State private var showingEmotionSheet = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let emotions = ["😊", "😌", "😮", "😨", "🤔", "😢", "😴", "🥰", "😎", "😭", "😱", "🤯", "😇"]
    let availableTags = ["海滩", "飞行", "迷宫", "自由", "恐惧", "水", "城市", "平静",
                         "探索", "追逐", "坠落", "考试", "工作", "家人", "朋友", "动物",
                         "太空", "旅行", "奇幻", "失落", "寻找", "战斗", "逃离"]
    
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
                            HStack {
                                Text("情绪:")
                                    .foregroundColor(Color("SubtitleColor"))
                                
                                Spacer()
                                
                                Button(action: {
                                    showingEmotionSheet = true
                                }) {
                                    Text("查看全部")
                                        .font(.caption)
                                        .foregroundColor(Color("AccentColor"))
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(emotions.prefix(7), id: \.self) { emotion in
                                        EmotionButton(
                                            emotion: emotion,
                                            isSelected: selectedEmotion == emotion,
                                            action: { selectedEmotion = emotion }
                                        )
                                    }
                                    
                                    // 添加自定义情绪按钮
                                    Button(action: {
                                        showingEmotionSheet = true
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
                            
                            HStack {
                                Text("模糊")
                                    .font(.caption)
                                    .foregroundColor(Color("SubtitleColor"))
                                
                                Spacer()
                                
                                Text("清晰")
                                    .font(.caption)
                                    .foregroundColor(Color("SubtitleColor"))
                            }
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
                            
                            // 显示当前录音文本（如果有）
                            if isRecording && !recordingText.isEmpty {
                                Text(recordingText)
                                    .font(.caption)
                                    .foregroundColor(Color("AccentColor"))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color("CardBackgroundColor").opacity(0.5))
                                    )
                            }
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
                                        Image(systemName: "mic.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20))
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
                            HStack {
                                Text("标签:")
                                    .foregroundColor(Color("SubtitleColor"))
                                
                                Spacer()
                                
                                Button(action: showTagPicker) {
                                    Label("添加标签", systemImage: "tag")
                                        .font(.caption)
                                        .foregroundColor(Color("AccentColor"))
                                }
                            }
                            
                            if selectedTags.isEmpty {
                                Text("点击添加标签按钮添加相关标签")
                                    .font(.caption)
                                    .foregroundColor(Color("MutedColor"))
                                    .padding(.vertical, 12)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(selectedTags, id: \.self) { tag in
                                            TagView(tag: tag, isSelected: true) {
                                                selectedTags.removeAll { $0 == tag }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 附加选项
                        VStack(alignment: .leading, spacing: 12) {
                            Text("附加选项:")
                                .font(.subheadline)
                                .foregroundColor(Color("SubtitleColor"))
                            
                            Toggle(isOn: $isLucidDream) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(Color("AccentColor"))
                                    Text("清醒梦")
                                        .foregroundColor(.white)
                                    
                                    Button(action: {
                                        showLucidDreamInfo()
                                    }) {
                                        Image(systemName: "info.circle")
                                            .font(.caption)
                                            .foregroundColor(Color("SubtitleColor"))
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                            
                            Toggle(isOn: $isFavorite) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text("收藏梦境")
                                        .foregroundColor(.white)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                        }
                        .padding()
                        .background(Color("CardBackgroundColor"))
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("记录新梦境")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
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
            .alert(isPresented: $showAuthorizationAlert) {
                Alert(
                    title: Text("需要权限"),
                    message: Text(authorizationAlertMessage),
                    dismissButton: .default(Text("好的"))
                )
            }
            .sheet(isPresented: $showingTagSheet) {
                TagPickerView(selectedTags: $selectedTags, availableTags: availableTags)
            }
            .sheet(isPresented: $showingEmotionSheet) {
                EmotionPickerView(selectedEmotion: $selectedEmotion, emotions: emotions)
            }
        }
    }
    
    // 保存梦境
    private func saveDream() {
        let newDream = Dream(
            title: dreamTitle.isEmpty ? "未命名梦境" : dreamTitle,
            dreamContent: dreamDescription,
            date: date,
            clarity: Int(clarity),
            emotion: selectedEmotion,
            tags: selectedTags,
            isFavorite: isFavorite,
            isLucidDream: isLucidDream
        )
        
        // 使用SwiftData保存新梦境
        modelContext.insert(newDream)
        
        // 返回上一页
        dismiss()
    }
    
    // 显示标签选择器
    func showTagPicker() {
        // 显示标签选择sheet
        showingTagSheet = true
    }
    
    // 显示清醒梦信息
    func showLucidDreamInfo() {
        authorizationAlertMessage = "清醒梦是指在梦中意识到自己正在做梦，并且可能有能力控制梦境内容的梦。勾选此选项表示这是一个清醒梦。"
        showAuthorizationAlert = true
    }
    
    // 请求语音识别权限
    func requestSpeechRecognitionAuthorization() {
        // 语音识别权限
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    // 用户授权了语音识别
                    print("语音识别已授权")
                    self.speechRecognitionEnabled = true
                    
                    // 同时请求麦克风权限
                    self.requestMicrophoneAuthorization()
                    
                case .denied:
                    // 用户拒绝了语音识别
                    print("语音识别授权被拒绝")
                    self.speechRecognitionEnabled = false
                    self.showAuthorizationAlert = true
                    self.authorizationAlertMessage = "要使用语音记录功能，请在设置中允许此应用使用语音识别。"
                    
                case .restricted, .notDetermined:
                    // 语音识别受限或未确定
                    print("语音识别权限受限或未确定")
                    self.speechRecognitionEnabled = false
                }
            }
        }
    }
    
    // 请求麦克风权限
        private func requestMicrophoneAuthorization() {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        // 用户授权了麦克风
                        print("麦克风已授权")
                        self.microphoneEnabled = true
                    } else {
                        // 用户拒绝了麦克风
                        print("麦克风授权被拒绝")
                        self.microphoneEnabled = false
                        self.showAuthorizationAlert = true
                        self.authorizationAlertMessage = "要使用语音记录功能，请在设置中允许此应用使用麦克风。"
                    }
                }
            }
        }
        
        // 开始录音
        func startRecording() {
            // 确保已获得所需权限
            guard speechRecognitionEnabled && microphoneEnabled else {
                print("缺少必要权限，无法开始录音")
                showAuthorizationAlert = true
                authorizationAlertMessage = "要使用语音记录功能，请在设置中允许此应用使用麦克风和语音识别。"
                return
            }
            
            // 检查语音识别是否可用
            guard let recognizer = speechRecognizer, recognizer.isAvailable else {
                print("语音识别器不可用")
                return
            }
            
            // 停止任何现有的识别任务
            if let recognitionTask = recognitionTask {
                recognitionTask.cancel()
                self.recognitionTask = nil
            }
            
            // 创建音频会话
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("设置音频会话失败: \(error)")
                return
            }
            
            // 创建识别请求
            self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            // 确保创建请求成功
            guard let recognitionRequest = recognitionRequest else {
                print("无法创建语音识别请求")
                return
            }
            
            // 配置请求选项
            recognitionRequest.shouldReportPartialResults = true
            
            // 创建输入节点
            let inputNode = audioEngine.inputNode
            
            // 开始识别任务
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    // 更新识别文本
                    DispatchQueue.main.async {
                        self.recordingText = result.bestTranscription.formattedString
                    }
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    // 停止音频引擎
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    DispatchQueue.main.async {
                        // 停止录音状态
                        self.isRecording = false
                        
                        // 将识别的文本添加到梦境描述
                        if !self.recordingText.isEmpty {
                            if self.dreamDescription.isEmpty {
                                self.dreamDescription = self.recordingText
                            } else {
                                self.dreamDescription += "\n\n" + self.recordingText
                            }
                            // 清空录音文本，为下次录音做准备
                            self.recordingText = ""
                        }
                    }
                }
            }
            
            // 配置音频格式
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            // 安装音频输入tap
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            // 启动音频引擎
            audioEngine.prepare()
            
            do {
                try audioEngine.start()
                DispatchQueue.main.async {
                    // 开始录音状态
                    self.isRecording = true
                }
            } catch {
                print("音频引擎启动失败: \(error)")
            }
        }
        
        // 停止录音
        func stopRecording() {
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                // 状态更新将在recognitionTask的完成回调中处理
            } else {
                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        }
}




