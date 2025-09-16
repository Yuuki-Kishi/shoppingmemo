//
//  User.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/25.
//

import Foundation

struct User: Codable, Hashable, Identifiable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    var id = UUID()
    var userId: String
    var userName: String
    var email: String
    var authority: [Authority]
    
    enum CodingKeys: String, CodingKey {
        case userId
        case userName
        case email
        case authority
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.email = try container.decode(String.self, forKey: .email)
        self.authority = try container.decode([Authority].self, forKey: .authority)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(userName, forKey: .userName)
        try container.encode(email, forKey: .email)
        try container.encode(authority, forKey: .authority)
    }
    
    init(userId: String, userName: String, email: String, authority: [Authority]) {
        self.userId = userId
        self.userName = userName
        self.email = email
        self.authority = authority
    }
    
    init(userId: String, creationDate)
    
    init() {
        self.userId = "unknownUserId"
        self.userName = "unknownUserName"
        self.email = "unknownUserEmail"
        self.authority = []
    }
}
