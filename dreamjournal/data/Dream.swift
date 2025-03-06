//
//  Dream.swift
//  DreamJournal
//
//  Created by kevin on 2025/3/6.
//

import Foundation

// 梦境数据模型
struct Dream: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var date: Date
    var clarity: Int // 1-10
    var emotion: String
    var tags: [String]
    
    // 添加更多属性
    var location: String?
    var isFavorite: Bool = false
    var isLucidDream: Bool = false
    var associatedDreams: [String] = [] // 关联梦境的ID
}
