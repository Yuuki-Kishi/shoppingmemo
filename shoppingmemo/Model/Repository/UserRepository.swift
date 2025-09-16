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
    
    //check
    
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
    
    //delete
    
    //observe
    static func observeUserData() {
        guard let userId = userDataStore.signInUser?.userId else { return }
        Firestore.firestore().collection("users").document(userId).addSnapshotListener() { documentSnapshot, error in
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
