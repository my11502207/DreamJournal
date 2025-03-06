//
//  EditDreamView.swift
//  dreamjournal
//
//  Created by kevin on 2025/3/6.
//

import SwiftUI

// 编辑梦境视图
struct EditDreamView: View {
    let dream: Dream
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String
    @State private var description: String
    
    init(dream: Dream) {
        self.dream = dream
        _title = State(initialValue: dream.title)
        _description = State(initialValue: dream.description)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("梦境标题", text: $title)
                    .padding()
                    .background(Color("CardBackgroundColor"))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                TextEditor(text: $description)
                    .padding(4)
                    .background(Color("CardBackgroundColor"))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
            .navigationTitle("编辑梦境")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // 保存编辑后的梦境
                        updateDream()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func updateDream() {
        // 更新梦境数据
        print("更新梦境: \(title), \(description)")
    }
}
