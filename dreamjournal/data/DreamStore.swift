//
//  DreamStore.swift
//  DreamJournal
//
//  Created by kevin on 2025/3/6.
//

import Foundation

// 梦境数据存储
class DreamStore: ObservableObject {
    @Published var dreams: [Dream] = []
    private let savePath = FileManager.documentsDirectory.appendingPathComponent("dreams.json")
    
    init() {
        loadDreams()
    }
    
    // 加载梦境数据
    func loadDreams() {
        do {
            let data = try Data(contentsOf: savePath)
            dreams = try JSONDecoder().decode([Dream].self, from: data)
        } catch {
            // 首次启动或出错时加载示例数据
            loadSampleDreams()
        }
    }
    
    // 保存梦境数据
    func saveDreams() {
        do {
            let data = try JSONEncoder().encode(dreams)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("无法保存梦境: \(error.localizedDescription)")
        }
    }
    
    // 添加新梦境
    func addDream(_ dream: Dream) {
        dreams.insert(dream, at: 0)
        saveDreams()
    }
    
    // 更新梦境
    func updateDream(_ dream: Dream) {
        if let index = dreams.firstIndex(where: { $0.id == dream.id }) {
            dreams[index] = dream
            saveDreams()
        }
    }
    
    // 删除梦境
    func deleteDream(_ id: String) {
        dreams.removeAll { $0.id == id }
        saveDreams()
    }
    
    // 加载示例数据
    private func loadSampleDreams() {
        dreams = [
            Dream(id: "1", title: "飞行梦", dreamContent: "我梦见自己在城市上空飞行，感觉非常自由...", date: Date(), clarity: 8, emotion: "😮", tags: ["飞行", "城市", "自由"]),
            Dream(id: "2", title: "迷宫梦", dreamContent: "在一个复杂的迷宫中寻找出口，墙壁不断变化...", date: Date().addingTimeInterval(-86400), clarity: 6, emotion: "😨", tags: ["迷宫", "寻找", "恐惧"]),
            Dream(id: "3", title: "海边漫步", dreamContent: "我梦见自己在一个安静的海滩上漫步，海浪声非常清晰...", date: Date().addingTimeInterval(-3*86400), clarity: 9, emotion: "😌", tags: ["海滩", "平静", "水"])
        ]
    }
}
