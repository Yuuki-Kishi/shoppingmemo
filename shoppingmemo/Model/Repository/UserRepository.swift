//
//  UserRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/16.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class UserRepository {
    static let userDataStore = UserDataStore.shared
    
    //create
    static func create(userId: String, email: String, creationTime: Date) async -> User? {
        do {
            let user = User(userId: userId, email: email, creationTime: creationTime)
            let encoded = try JSONEncoder().encode(user)
            guard let jsonObject = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any] else { return nil }
            try await Firestore.firestore().collection("users").addDocument(data: jsonObject)
            return user
        } catch {
            print(error)
            return nil
        }
    }
    
    //check
    static func isExist(userId: String) async -> Bool {
        do {
            let isExist = try await Firestore.firestore().collection("users").document(userId).getDocument().exists
            return isExist
        } catch {
            print(error)
            return false
        }
    }
    
    static func notExistPropaties(userId: String) async -> [String] {
        do {
            var notExistPropaties: [String] = []
            let checkPropaties: [String] = ["creationTime", "currentVersion", "email", "iOSVersion", "noticeCheckedTime", "userName"]
            let document = try await Firestore.firestore().collection("users").document(userId).getDocument()
            for checkPropaty in checkPropaties {
                if let _ = document.get(checkPropaty) { continue }
                else { notExistPropaties.append(checkPropaty) }
            }
            return notExistPropaties
        } catch {
            print(error)
            return []
        }
    }
    
    //get
    static func getUserData(userId: String) async -> User? {
        do {
            let document = try await Firestore.firestore().collection("users").document(userId).getDocument()
            let user = try document.data(as: User.self)
            return user
        } catch {
            print(error)
            return nil
        }
    }
    
    //update
    static func addPropaties(userId: String, propaties: [String: Any]) async {
        do {
            for propaty in propaties {
                try await Firestore.firestore().collection("users").document(userId).updateData([propaty.key: propaty.value])
            }
        } catch {
            print(error)
            return
        }
    }
    
    static func addMyRoom(roomId: String, ownAuthority: Authority.AuthorityEnum) async {
        do {
            guard let userId = userDataStore.signInUser?.userId else { return }
            let authority = Authority(roomId: roomId, authority: ownAuthority)
            let encoded = try JSONEncoder().encode(authority)
            guard let jsonObject = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any] else { return }
            try await Firestore.firestore().collection("users").document(userId).updateData(["authorities": FieldValue.arrayUnion([jsonObject])])
        } catch {
            print(error)
        }
    }
    
    //delete
    
    //observe
    static func observeMyFieldValue() {
        guard let userId = userDataStore.signInUser?.userId else { return }
        Firestore.firestore().collection("users").document(userId).addSnapshotListener() { documentSnapshot, error in
            Task {
                do {
                    guard let user = try documentSnapshot?.data(as: User.self) else { return }
                    await RoomRepository.updateRooms(authorities: user.authorities)
                    userDataStore.userResult = .success(user)
                    userDataStore.signInUser = user
                } catch {
                    print(error)
                }
            }
        }
    }
}
