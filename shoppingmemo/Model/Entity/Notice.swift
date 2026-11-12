//
//  Notice.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/18.
//

import Foundation

struct Notice: Codable, Hashable, Identifiable {
    var id = UUID()
    var noticeId: String
    var noticeTitle: String
    var noticeContent: String
    var creationDate: Date
    
    enum CodingKeys: String, CodingKey {
        case noticeId, noticeTitle, noticeContent, creationDate
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.noticeId = try container.decode(String.self, forKey: .noticeId)
        self.noticeTitle = try container.decode(String.self, forKey: .noticeTitle)
        self.noticeContent = try container.decode(String.self, forKey: .noticeContent)
        let formatter = ISO8601DateFormatter()
        let dateString = try container.decode(String.self, forKey: .creationDate)
        if let date = formatter.date(from: dateString) {
            self.creationDate = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .creationDate, in: container, debugDescription: "Failed to decode creationTime.")
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(noticeId, forKey: .noticeId)
        try container.encode(noticeTitle, forKey: .noticeTitle)
        try container.encode(noticeContent, forKey: .noticeContent)
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: creationDate)
        try container.encode(dateString, forKey: .creationDate)
    }
    
    init() {
        self.noticeId = "unknownNoticeId"
        self.noticeTitle = "unknownNoticeTitle"
        self.noticeContent = "unknownNoticeContent"
        self.creationDate = Date()
    }
}

@MainActor
extension Array where Element == Notice {
    var selected: Element? {
        guard let selectedNoticeId = NoticeDataStore.shared.selectedNoticeId else { return nil }
        return self.first { $0.noticeId == selectedNoticeId }
    }
    mutating func append(noDuplicate notice: Element) {
        if let index = self.firstIndex(of: notice) {
            self[index] = notice
        } else {
            self.append(notice)
        }
    }
    mutating func remove(notice: Element) {
        if let index = self.firstIndex(of: notice) {
            self.remove(at: index)
        }
    }
}
