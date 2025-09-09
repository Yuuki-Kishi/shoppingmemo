//
//  Member.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/04.
//

import Foundation

struct Member: Codable, Hashable, Identifiable, Equatable {
    static func == (lhs: Member, rhs: Member) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    var id = UUID()
    var userId: String
    var email: String
    var authority: authorityEnum
    
    enum authorityEnum: String {
        case administrator, member, guest, unknwon
    }
    
    enum CodingKeys: String, CodingKey {
        case userId, email, authority
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decode(String.self, forKey: .email)
        let authorityString = try container.decode(String.self, forKey: .authority)
        self.authority = authorityEnum(rawValue: authorityString) ?? .unknwon
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(email, forKey: .email)
        try container.encode(authority.rawValue, forKey: .authority)
    }
    
    init(userId: String, email: String, authority: authorityEnum) {
        self.userId = userId
        self.email = email
        self.authority = authority
    }
    
    init() {
        self.userId = "unknownUserId"
        self.email = "unknownUserEmail"
        self.authority = .unknwon
    }
}
