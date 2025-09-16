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
    var lastUpdateUserId: String
    var lastUpdateTime: Date
    var ownAuthority: OwnAuthorityEnum
    
    enum OwnAuthorityEnum: String {
        case administrator, member, guest, unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case roomId, roomName, creationTime, lastUpdateUserId, lastUpdateTime, ownAuthority
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
        self.lastUpdateUserId = try container.decode(String.self, forKey: .lastUpdateUserId)
        let lastUpdateTimeString = try container.decode(String.self, forKey: .lastUpdateTime)
        if let date = formatter.date(from: lastUpdateTimeString) {
            self.lastUpdateTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .lastUpdateTime, in: container, debugDescription: "Failed to decode lastUpdateTime.")
        }
        self.ownAuthority = .unknown
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.roomId, forKey: .roomId)
        try container.encode(self.roomName, forKey: .roomName)
        let formatter = ISO8601DateFormatter()
        let creationTimeString = formatter.string(from: self.creationTime)
        try container.encode(creationTimeString, forKey: .creationTime)
        try container.encode(self.lastUpdateUserId, forKey: .lastUpdateUserId)
        let lastUpdateTimeString = formatter.string(from: self.lastUpdateTime)
        try container.encode(lastUpdateTimeString, forKey: .lastUpdateTime)
    }
    
    init(roomId: String, roomName: String, creationTime: Date, lastUpdateUserId: String, lastUpdateTime: Date, ownAuthority: OwnAuthorityEnum) {
        self.roomId = roomId
        self.roomName = roomName
        self.creationTime = creationTime
        self.lastUpdateUserId = lastUpdateUserId
        self.lastUpdateTime = lastUpdateTime
        self.ownAuthority = ownAuthority
    }
    
    init() {
        self.roomId = "unknownRoomId"
        self.roomName = "unknownRoomName"
        self.creationTime = Date()
        self.lastUpdateUserId = "unknownUserId"
        self.lastUpdateTime = Date()
        self.ownAuthority = .unknown
    }
}

extension Array where Element == Room {
    mutating func append(noDupulicate room: Room) {
        if let index = self.firstIndex(of: room) {
            self[index] = room
        } else {
            self.append(room)
        }
    }
    mutating func remove(room: Room) {
        if let index = self.firstIndex(of: room) {
            self.remove(at: index)
        }
    }
}
