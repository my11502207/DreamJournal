import SwiftUI
import SwiftData

struct EditDreamView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var dream: Dream
    
    @State private var title: String
    @State private var dreamContent: String
    @State private var emotion: String
    @State private var clarity: Double
    @State private var date: Date
    @State private var tags: [String]
    @State private var isLucidDream: Bool
    @State private var isFavorite: Bool
    @State private var newTag: String = ""
    @State private var showingTagSheet = false
    
    let emotions = ["😊", "😌", "😮", "😨", "🤔", "😢"]
    let availableTags = ["海滩", "飞行", "迷宫", "自由", "恐惧", "水", "城市", "平静", "追逐", "坠落", "探索", "动物"]
    
    init(dream: Dream) {
        self.dream = dream
        _title = State(initialValue: dream.title)
        _dreamContent = State(initialValue: dream.dreamContent)
        _emotion = State(initialValue: dream.emotion)
        _clarity = State(initialValue: Double(dream.clarity))
        _date = State(initialValue: dream.date)
        _tags = State(initialValue: dream.tags)
        _isLucidDream = State(initialValue: dream.isLucidDream)
        _isFavorite = State(initialValue: dream.isFavorite)
    }
    
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
                            
                            TextField("为你的梦境取个标题", text: $title)
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
                                    ForEach(emotions, id: \.self) { currentEmotion in
                                        EmotionButton(
                                            emotion: currentEmotion,
                                            isSelected: emotion == currentEmotion,
                                            action: { emotion = currentEmotion }
                                        )
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
                            
                            TextEditor(text: $dreamContent)
                                .frame(minHeight: 150)
                                .padding(4)
                                .background(Color("CardBackgroundColor"))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        // 标签选择
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("标签:")
                                    .foregroundColor(Color("SubtitleColor"))
                                
                                Spacer()
                                
                                Button(action: {
                                    showingTagSheet = true
                                }) {
                                    Label("添加标签", systemImage: "plus")
                                        .font(.caption)
                                        .foregroundColor(Color("AccentColor"))
                                }
                            }
                            
                            if tags.isEmpty {
                                Text("点击上方按钮添加标签")
                                    .font(.caption)
                                    .foregroundColor(Color("MutedColor"))
                                    .padding(.vertical, 8)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(tags, id: \.self) { tag in
                                            TagView(tag: tag, isSelected: true) {
                                                tags.removeAll { $0 == tag }
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
                .sheet(isPresented: $showingTagSheet) {
                    TagSelectionView(selectedTags: $tags, availableTags: availableTags)
                        .presentationDetents([.medium, .large])
                }
            }
            .navigationTitle("编辑梦境")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: updateDream) {
                        Text("保存")
                            .fontWeight(.medium)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
        }
    }
    
    // 更新梦境
    private func updateDream() {
        dream.title = title
        dream.dreamContent = dreamContent
        dream.emotion = emotion
        dream.clarity = Int(clarity)
        dream.date = date
        dream.tags = tags
        dream.isLucidDream = isLucidDream
        dream.isFavorite = isFavorite
        
        // SwiftData会自动保存更改
        dismiss()
    }
}

// 标签选择视图
struct TagSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTags: [String]
    let availableTags: [String]
    @State private var newTagText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // 搜索/添加新标签
                HStack {
                    TextField("添加新标签", text: $newTagText)
                        .padding()
                        .background(Color("CardBackgroundColor"))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    Button(action: addNewTag) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color("AccentColor"))
                            .font(.title2)
                    }
                    .disabled(newTagText.isEmpty)
                }
                .padding()
                
                // 可用标签列表
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("可用标签")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(availableTags.sorted(), id: \.self) { tag in
                                TagView(
                                    tag: tag,
                                    isSelected: selectedTags.contains(tag)
                                ) {
                                    toggleTag(tag)
                                }
                            }
                            
                            // 用户添加的自定义标签
                            ForEach(customTags.sorted(), id: \.self) { tag in
                                TagView(
                                    tag: tag,
                                    isSelected: selectedTags.contains(tag)
                                ) {
                                    toggleTag(tag)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 确定按钮
                Button("完成") {
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("AccentColor"))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
            .background(Color("BackgroundColor"))
            .navigationTitle("选择标签")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 添加新标签
    private func addNewTag() {
        guard !newTagText.isEmpty else { return }
        
        let newTag = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !selectedTags.contains(newTag) && !availableTags.contains(newTag) {
            selectedTags.append(newTag)
        } else if !selectedTags.contains(newTag) {
            selectedTags.append(newTag)
        }
        
        newTagText = ""
    }
    
    // 切换标签选择状态
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }
    
    // 用户添加的自定义标签（排除预设标签）
    var customTags: [String] {
        selectedTags.filter { !availableTags.contains($0) }
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
