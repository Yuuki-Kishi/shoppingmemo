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
    var memberIds: [String]
    var authorities: [String: AuthorityEnum]
    
    enum AuthorityEnum: String, Codable {
        case administrator, member, guest, unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case roomId, roomName, creationTime, lastUpdateUserId, lastUpdateTime, memberIds, authorities
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
        self.memberIds = try container.decode([String].self, forKey: .memberIds)
        self.authorities = try container.decode([String: AuthorityEnum].self, forKey: .authorities)
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
        try container.encode(self.memberIds, forKey: .memberIds)
        try container.encode(self.authorities, forKey: .authorities)
    }
    
    init(roomId: String, roomName: String, creationTime: Date, lastUpdateUserId: String, lastUpdateTime: Date, memberIds: [String], authorities: [String: AuthorityEnum]) {
        self.roomId = roomId
        self.roomName = roomName
        self.creationTime = creationTime
        self.lastUpdateUserId = lastUpdateUserId
        self.lastUpdateTime = lastUpdateTime
        self.memberIds = memberIds
        self.authorities = authorities
    }
    
    init(roomName: String, userId: String) {
        let roomId = UUID().uuidString
        self.roomId = roomId
        self.roomName = roomName
        self.creationTime = Date()
        self.lastUpdateUserId = userId
        self.lastUpdateTime = Date()
        self.memberIds = [userId]
        self.authorities = [userId: .administrator]
    }
    
    init() {
        self.roomId = "unknownRoomId"
        self.roomName = "unknownRoomName"
        self.creationTime = Date()
        self.lastUpdateUserId = "unknownUserId"
        self.lastUpdateTime = Date()
        self.memberIds = ["unknownUserId"]
        self.authorities = ["unknownUserId": .unknown]
    }
}

@MainActor
extension Array where Element == Room {
    var selected: Element? {
        guard let selectedRoomId = RoomDataStore.shared.selectedRoomId else { return nil }
        return self.first(where: { $0.roomId == selectedRoomId })
    }
    mutating func append(noDuplicate room: Element) {
        if let index = self.firstIndex(of: room) {
            self[index] = room
        } else {
            self.append(room)
        }
    }
    mutating func remove(room: Element) {
        if let index = self.firstIndex(of: room) {
            self.remove(at: index)
        }
    }
}

@MainActor
extension Dictionary where Key == String, Value == Room.AuthorityEnum {
    var myAuthority: Value? {
        guard let userId = UserDataStore.shared.signInUser?.userId else { return nil }
        return self[userId]
    }
    var administrators: [Key] {
        self.filter { $0.value == .administrator }.map { $0.key }
    }
    var members: [Key] {
        self.filter { $0.value == .member }.map { $0.key }
    }
    var guests: [Key] {
        self.filter { $0.value == .guest }.map { $0.key }
    }
}

extension Room {
    mutating func authority(userId: String) -> AuthorityEnum? {
        self.authorities[userId]
    }
}
