//
//  MemberRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/24.
//

import Foundation
import FirebaseFirestore

@MainActor
class MemberRepository {
    static let userDataStore: UserDataStore = .shared
    static let roomDataStore: RoomDataStore = .shared
    
    //create
    static func createMember(roomId: String, authority: Authority.AuthorityEnum) async {
        do {
            guard let userId = userDataStore.signInUser?.userId else { return }
            guard let email = userDataStore.signInUser?.email else { return }
            let member = Member(userId: userId, email: email, authority: authority)
            let encoded = try JSONEncoder().encode(member)
            guard let jsonObject = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any] else { return }
            try await Firestore.firestore().collection("rooms").document(roomId).collection("members").document(userId).setData(jsonObject)
        } catch {
            print(error)
        }
    }
}
