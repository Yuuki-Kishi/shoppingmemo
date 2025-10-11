//
//  Authority.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/25.
//

import Foundation

struct Authority: Codable, Hashable, Identifiable, Equatable {
    static func == (lhs: Authority, rhs: Authority) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    var id = UUID()
    var userId: String
    var authority: AuthorityEnum
    
    enum AuthorityEnum: String {
        case administrator, member, guest, unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case userId, authority
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        let authorityString = try container.decode(String.self, forKey: .authority)
        self.authority = AuthorityEnum(rawValue: authorityString) ?? .unknown
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(authority.rawValue, forKey: .authority)
    }
    
    init(userId: String, authority: AuthorityEnum) {
        self.userId = userId
        self.authority = authority
    }
    
    init() {
        self.userId = "unknownUserId"
        self.authority = .unknown
    }
}

@MainActor
extension Array where Element == Authority {
    var mine: Authority.AuthorityEnum {
        guard let userId = UserDataStore.shared.signInUser?.userId else { return .unknown }
        if let mine = self.first(where: { $0.userId == userId }) {
            return mine.authority
        }
        return .unknown
    }
}
