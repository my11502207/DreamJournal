//
//  FileManager.swift
//  DreamJournal
//
//  Created by kevin on 2025/3/6.
//

import Foundation

// FileManager扩展 - 获取Documents目录
extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
