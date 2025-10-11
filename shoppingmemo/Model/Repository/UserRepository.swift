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
            try await Firestore.firestore().collection("Users").addDocument(data: jsonObject)
            return user
        } catch {
            print(error)
            return nil
        }
    }
    
    //check
    static func isExist(userId: String) async -> Bool {
        do {
            let isExist = try await Firestore.firestore().collection("Users").document(userId).getDocument().exists
            return isExist
        } catch {
            print(error)
            return false
        }
    }
    
    static func isNeedCompensate() async -> Bool {
        do {
            guard let userId = Auth.auth().currentUser?.uid else { return false }
            let document = try await Firestore.firestore().collection("Users").document(userId).getDocument()
            guard let creationTime = document["creationTime"] as? String else { return true }
            guard let currentVersion = document["currentVersion"] as? String else { return true}
            guard let email = document["email"] as? String else { return true }
            guard let iOSVersion = document["iOSVersion"] as? String else { return true }
            guard let noticeCheckedTime = document["noticeCheckedTime"] as? String else { return true }
            return false
        } catch {
            print(error)
            return false
        }
    }
    
    //get
    static func getUserData(userId: String) async -> User? {
        do {
            let document = try await Firestore.firestore().collection("Users").document(userId).getDocument()
            let user = try document.data(as: User.self)
            return user
        } catch {
            print(error)
            return nil
        }
    }
    
    //update
    static func compensatePropaties() async {
        do {
            let formatter = ISO8601DateFormatter()
            guard let creationTime = Auth.auth().currentUser?.metadata.creationDate else { return }
            let creationTimeString = formatter.string(from: creationTime)
            guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return }
            guard let email = Auth.auth().currentUser?.email else { return }
            let iOSVersion = UIDevice.current.systemVersion
            let noticeCheckedTime: String = "2025-01-01T00:00:00Z"
            guard let userId = Auth.auth().currentUser?.uid else { return }
            try await Firestore.firestore().collection("Users").document(userId).updateData(["creationTime": creationTimeString, "currentVersion": currentVersion, "email": email, "iOSVersion": iOSVersion, "noticeCheckedTime": noticeCheckedTime, "userId": userId])
        } catch {
            print(error)
            return
        }
    }
    
    //delete
    
    //observe
    static func observeUserData() {
        guard let userId = userDataStore.signInUser?.userId else { return }
        Firestore.firestore().collection("Users").document(userId).addSnapshotListener { documentSnapshot, error in
            do {
                let user = try documentSnapshot?.data(as: User.self)
                userDataStore.userResult = .success(user)
                userDataStore.signInUser = user
            } catch {
                print(error)
            }
        }
    }
}
