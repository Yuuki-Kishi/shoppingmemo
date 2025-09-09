//
//  Authority.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/25.
//

import Foundation

struct Authority: Codable, Hashable, Identifiable, Equatable {
    static func == (lhs: Authority, rhs: Authority) -> Bool {
        return lhs.roomId == rhs.roomId
    }
    
    var id = UUID()
    var roomId: String
    var authority: AuthorityEnum
    
    enum AuthorityEnum: String {
        case administrator, member, guest, unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case roomId, authority
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.roomId = try container.decode(String.self, forKey: .roomId)
        let authorityString = try container.decode(String.self, forKey: .authority)
        self.authority = AuthorityEnum(rawValue: authorityString) ?? .unknown
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(roomId, forKey: .roomId)
        try container.encode(authority.rawValue, forKey: .authority)
    }
    
    init(roomId: String, authority: AuthorityEnum) {
        self.roomId = roomId
        self.authority = authority
    }
    
    init() {
        self.roomId = "unknownRoomId"
        self.authority = .unknown
    }
}
