import SwiftUI

// 标签选择视图
struct TagPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTags: [String]
    let availableTags: [String]
    @State private var newTagText = ""
    @State private var searchText = ""
    
    var filteredTags: [String] {
        if searchText.isEmpty {
            return availableTags
        } else {
            return availableTags.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    // 搜索/添加新标签
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("SubtitleColor"))
                            .padding(.leading, 8)
                        
                        TextField("搜索或添加新标签", text: $newTagText)
                            .padding(10)
                            .background(Color("CardBackgroundColor"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .onChange(of: newTagText) { newValue in
                                searchText = newValue
                            }
                        
                        Button(action: addNewTag) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color("AccentColor"))
                                .font(.title2)
                        }
                        .disabled(newTagText.isEmpty)
                        .padding(.trailing, 8)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("CardBackgroundColor"))
                    )
                    .padding(.horizontal)
                    
                    if !selectedTags.isEmpty {
                        // 已选标签区域
                        VStack(alignment: .leading, spacing: 8) {
                            Text("已选标签")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.leading)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(selectedTags, id: \.self) { tag in
                                        TagView(tag: tag, isSelected: true) {
                                            selectedTags.removeAll { $0 == tag }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 可用标签列表
                    VStack(alignment: .leading) {
                        Text(searchText.isEmpty ? "可用标签" : "搜索结果")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        if filteredTags.isEmpty && !searchText.isEmpty {
                            VStack(spacing: 10) {
                                Text("未找到匹配标签")
                                    .foregroundColor(Color("SubtitleColor"))
                                
                                Button(action: {
                                    addCustomTag(searchText)
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                            .font(.caption)
                                        
                                        Text("添加 \"\(searchText)\" 作为新标签")
                                            .font(.subheadline)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color("CardBackgroundColor"))
                                    )
                                    .foregroundColor(Color("AccentColor"))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                ForEach(filteredTags, id: \.self) { tag in
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
                            .padding(.top, 4)
                        }
                    }
                    
                    Spacer()
                    
                    // 按钮栏
                    HStack {
                        Button("清空选择") {
                            selectedTags.removeAll()
                        }
                        .foregroundColor(Color("SubtitleColor"))
                        .disabled(selectedTags.isEmpty)
                        
                        Spacer()
                        
                        Button("完成") {
                            dismiss()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color("CardBackgroundColor"))
                }
            }
            .navigationTitle("选择标签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // 添加新标签
    private func addNewTag() {
        guard !newTagText.isEmpty else { return }
        
        addCustomTag(newTagText)
        newTagText = ""
        searchText = ""
    }
    
    // 添加自定义标签
    private func addCustomTag(_ tagText: String) {
        let tag = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty else { return }
        
        if !selectedTags.contains(tag) {
            selectedTags.append(tag)
        }
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

// 情绪选择视图
struct EmotionPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEmotion: String
    let emotions: [String]
    
    // 将情绪分成多个部分以便布局
    var groupedEmotions: [[String]] {
        var result: [[String]] = []
        var currentGroup: [String] = []
        
        for (index, emotion) in emotions.enumerated() {
            currentGroup.append(emotion)
            
            if currentGroup.count == 5 || index == emotions.count - 1 {
                result.append(currentGroup)
                currentGroup = []
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("选择表示梦境情绪的表情")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    VStack(spacing: 15) {
                        ForEach(groupedEmotions, id: \.self) { group in
                            HStack(spacing: 15) {
                                ForEach(group, id: \.self) { emotion in
                                    EmotionButton(
                                        emotion: emotion,
                                        isSelected: selectedEmotion == emotion,
                                        action: {
                                            selectedEmotion = emotion
                                            // 选择后短暂延迟关闭，提供反馈
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                dismiss()
                                            }
                                        }
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                                
                                // 确保每行都有相同数量的元素
                                if group.count < 5 {
                                    ForEach(0..<(5-group.count), id: \.self) { _ in
                                        Spacer()
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("CardBackgroundColor"))
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("选择情绪")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}
