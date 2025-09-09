//
//  Room.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/28.
//

import Foundation

struct Room: Codable, Hashable, Identifiable, Equatable {
    static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs.roomId == rhs.roomId
    }
    
    var id = UUID()
    var roomId: String
    var roomName: String
    var creationTime: Date
    var lastEditUserId: String
    var lastEditTime: Date
    var members: [Member]
    
    enum CodingKeys: String, CodingKey {
        case roomId, roomName, creationTime, lastEditUserId, lastEditTime, members
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.roomId = try container.decode(String.self, forKey: .roomId)
        self.roomName = try container.decode(String.self, forKey: .roomName)
        let formatter = ISO8601DateFormatter()
        let creationTimeString = try container.decode(String.self, forKey: .creationTime)
        if let date = formatter.date(from: creationTimeString) {
            self.creationTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .creationTime, in: container, debugDescription: "Failed to decode creationTime.")
        }
        self.lastEditUserId = try container.decode(String.self, forKey: .lastEditUserId)
        let lastEditTimeString = try container.decode(String.self, forKey: .lastEditTime)
        if let date = formatter.date(from: lastEditTimeString) {
            self.lastEditTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .lastEditTime, in: container, debugDescription: "Failed to decode lastEditTime.")
        }
        self.members = try container.decode([Member].self, forKey: .members)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.roomId, forKey: .roomId)
        try container.encode(self.roomName, forKey: .roomName)
        let formatter = ISO8601DateFormatter()
        let creationTimeString = formatter.string(from: self.creationTime)
        try container.encode(creationTimeString, forKey: .creationTime)
        try container.encode(self.lastEditUserId, forKey: .lastEditUserId)
        let lastEditTimeString = formatter.string(from: self.lastEditTime)
        try container.encode(lastEditTimeString, forKey: .lastEditTime)
        try container.encode(self.members, forKey: .members)
    }
    
    init(roomId: String, roomName: String, creationTime: Date, lastEditUserId: String, lastEditTime: Date, members: [Member]) {
        self.roomId = roomId
        self.roomName = roomName
        self.creationTime = creationTime
        self.lastEditUserId = lastEditUserId
        self.lastEditTime = lastEditTime
        self.members = members
    }
    
    init() {
        self.roomId = "unknownRoomId"
        self.roomName = "unknownRoomName"
        self.creationTime = Date()
        self.lastEditUserId = "unknownUserId"
        self.lastEditTime = Date()
        self.members = []
    }
}
