//
//  Participant.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import Foundation

struct Participant: Hashable, Identifiable, Equatable {
    static func == (lhs: Participant, rhs: Participant) -> Bool {
        lhs.userId == rhs.userId
    }
    
    var id = UUID()
    var userId: String
    var authority: Authority.AuthorityEnum
    var userName: String?
    var email: String?
    
    init(userId: String, authority: Authority.AuthorityEnum, userName: String?, email: String?) {
        self.userId = userId
        self.authority = authority
        self.userName = userName
        self.email = email
    }
    
    init() {
        self.userId = "unknownUserId"
        self.authority = .member
        self.userName = nil
        self.email = nil
    }
}

@MainActor
extension Array where Element == Participant {
    var myParticipant: Participant? {
        guard let userId = UserDataStore.shared.signInUser?.userId else { return nil }
        return self.first(where: { $0.userId == userId })
    }
    mutating func append(noDuplicate item: Element) {
        if let index = self.firstIndex(where: { $0.userId == item.userId }) {
            self[index] = item
        } else {
            self.append(item)
        }
    }
    mutating func updateUserNameAndEmail(userId: String, userName: String, email: String) {
        if var participant = self.first(where: { $0.userId == userId }) {
            participant.userName = userName
            participant.email = email
            self.append(noDuplicate: participant)
        }
    }
    mutating func remove(authority: Element) {
        if let index = self.firstIndex(where: { $0.userId == authority.userId }) {
            self.remove(at: index)
        }
    }
    var administrators: [Element] {
        self.filter { $0.authority == .administrator }
    }
    var members: [Element] {
        self.filter { $0.authority == .member }
    }
    var guests: [Element] {
        self.filter { $0.authority == .guest }
    }
}
