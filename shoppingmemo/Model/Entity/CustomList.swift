//
//  List.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/28.
//

import Foundation

struct CustomList: Codable, Hashable, Identifiable, Equatable {
    static func == (lhs: CustomList, rhs: CustomList) -> Bool {
        return lhs.listId == rhs.listId
    }
    
    var id = UUID()
    var listId: String
    var listName: String
    var creationTime: Date
    var listOrder: Int
    var lastUpdateUserId: String
    var lastUpdateTime: Date
    
    enum CodingKeys: String, CodingKey {
        case listId, listName, creationTime, listOrder, lastUpdateUserId, lastUpdateTime
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.listId = try container.decode(String.self, forKey: .listId)
        self.listName = try container.decode(String.self, forKey: .listName)
        let formatter = ISO8601DateFormatter()
        let creationTimeString = try container.decode(String.self, forKey: .creationTime)
        if let date = formatter.date(from: creationTimeString) {
            self.creationTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .creationTime, in: container, debugDescription: "Failed to decode creationTime.")
        }
        self.listOrder = try container.decode(Int.self, forKey: .listOrder)
        self.lastUpdateUserId = try container.decode(String.self, forKey: .lastUpdateUserId)
        let lastUpdateTimeString = try container.decode(String.self, forKey: .lastUpdateTime)
        if let date = formatter.date(from: lastUpdateTimeString) {
            self.lastUpdateTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .lastUpdateTime, in: container, debugDescription: "Failed to decode lastUpdateTime.")
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.listId, forKey: .listId)
        try container.encode(self.listName, forKey: .listName)
        let formatter = ISO8601DateFormatter()
        let creationTimeString = formatter.string(from: self.creationTime)
        try container.encode(creationTimeString, forKey: .creationTime)
        try container.encode(self.listOrder, forKey: .listOrder)
        try container.encode(self.lastUpdateUserId, forKey: .lastUpdateUserId)
        let lastUpdateTimeString = formatter.string(from: self.lastUpdateTime)
        try container.encode(lastUpdateTimeString, forKey: .lastUpdateTime)
    }
    
    init(listId: String, listName: String, creationTime: Date, listOrder: Int, lastUpdateUserId: String, lastUpdateTime: Date) {
        self.listId = listId
        self.listName = listName
        self.creationTime = creationTime
        self.listOrder = listOrder
        self.lastUpdateUserId = lastUpdateUserId
        self.lastUpdateTime = lastUpdateTime
    }
    
    init() {
        self.listId = "unknownListId"
        self.listName = "unknownListName"
        self.creationTime = Date()
        self.listOrder = 0
        self.lastUpdateUserId = "unknownUserId"
        self.lastUpdateTime = Date()
    }
}
