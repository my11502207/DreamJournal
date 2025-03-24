//
//  DreamCompatibility.swift
//  DreamJournal
//

import Foundation

// 为Dream添加兼容扩展，方便从旧的Dream JSON解码
extension Dream {
    // 提供对旧版"description"字段的访问
    var description: String {
        get { return dreamContent }
        set { dreamContent = newValue }
    }
    
    // 支持从旧版JSON数据解码（包含description字段而不是dreamContent）
    struct LegacyKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        
        static let description = LegacyKeys(stringValue: "description")!
        static let dreamContent = LegacyKeys(stringValue: "dreamContent")!
    }
    
    // 用于将旧版数据导入到新版Dream模型
    static func importFromLegacyData(_ jsonData: Data) throws -> [Dream] {
        let decoder = JSONDecoder()
        
        // 设置日期解码策略
        decoder.dateDecodingStrategy = .iso8601
        
        // 自定义解码逻辑处理旧版数据
        class LegacyDreamDecoder: Decodable {
            enum CodingKeys: String, CodingKey {
                case id, title, description, date, clarity, emotion, tags
                case location, isFavorite, isLucidDream, associatedDreams
            }
            
            let id: String
            let title: String
            let dreamContent: String
            let date: Date
            let clarity: Int
            let emotion: String
            let tags: [String]
            let location: String?
            let isFavorite: Bool
            let isLucidDream: Bool
            let associatedDreams: [String]
            
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                title = try container.decode(String.self, forKey: .title)
                // 尝试从description字段读取内容
                dreamContent = try container.decode(String.self, forKey: .description)
                date = try container.decode(Date.self, forKey: .date)
                clarity = try container.decode(Int.self, forKey: .clarity)
                emotion = try container.decode(String.self, forKey: .emotion)
                tags = try container.decode([String].self, forKey: .tags)
                location = try container.decodeIfPresent(String.self, forKey: .location)
                isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
                isLucidDream = try container.decodeIfPresent(Bool.self, forKey: .isLucidDream) ?? false
                associatedDreams = try container.decodeIfPresent([String].self, forKey: .associatedDreams) ?? []
            }
            
            // 转换为Dream对象
            func toDream() -> Dream {
                return Dream(
                    id: id,
                    title: title,
                    dreamContent: dreamContent,
                    date: date,
                    clarity: clarity,
                    emotion: emotion,
                    tags: tags,
                    location: location,
                    isFavorite: isFavorite,
                    isLucidDream: isLucidDream,
                    associatedDreams: associatedDreams
                )
            }
        }
        
        // 解码旧版数据并转换为新版Dream对象
        let legacyDreams = try decoder.decode([LegacyDreamDecoder].self, from: jsonData)
        return legacyDreams.map { $0.toDream() }
    }
}
