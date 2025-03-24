//
//  Dream.swift
//  DreamJournal
//

import Foundation
import SwiftData

// 梦境数据模型 - 使用SwiftData 且支持 Codable
@Model
final class Dream: Codable {
    var id: String
    var title: String
    var dreamContent: String  // 重命名的描述字段
    var date: Date
    var clarity: Int // 1-10
    var emotion: String
    var tags: [String]
    
    // 添加更多属性
    var location: String?
    var isFavorite: Bool
    var isLucidDream: Bool
    var associatedDreams: [String] // 关联梦境的ID
    
    init(
        id: String = UUID().uuidString,
        title: String,
        dreamContent: String,
        date: Date,
        clarity: Int,
        emotion: String,
        tags: [String],
        location: String? = nil,
        isFavorite: Bool = false,
        isLucidDream: Bool = false,
        associatedDreams: [String] = []
    ) {
        self.id = id
        self.title = title
        self.dreamContent = dreamContent
        self.date = date
        self.clarity = clarity
        self.emotion = emotion
        self.tags = tags
        self.location = location
        self.isFavorite = isFavorite
        self.isLucidDream = isLucidDream
        self.associatedDreams = associatedDreams
    }
    
    // 实现 Encodable 协议所需的 encode 方法
    enum CodingKeys: String, CodingKey {
        case id, title, dreamContent, date, clarity, emotion, tags
        case location, isFavorite, isLucidDream, associatedDreams
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dreamContent, forKey: .dreamContent)
        try container.encode(date, forKey: .date)
        try container.encode(clarity, forKey: .clarity)
        try container.encode(emotion, forKey: .emotion)
        try container.encode(tags, forKey: .tags)
        try container.encode(location, forKey: .location)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(isLucidDream, forKey: .isLucidDream)
        try container.encode(associatedDreams, forKey: .associatedDreams)
    }
    
    // 实现 Decodable 协议所需的初始化方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        dreamContent = try container.decode(String.self, forKey: .dreamContent)
        date = try container.decode(Date.self, forKey: .date)
        clarity = try container.decode(Int.self, forKey: .clarity)
        emotion = try container.decode(String.self, forKey: .emotion)
        tags = try container.decode([String].self, forKey: .tags)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        isLucidDream = try container.decode(Bool.self, forKey: .isLucidDream)
        associatedDreams = try container.decode([String].self, forKey: .associatedDreams)
    }
}
