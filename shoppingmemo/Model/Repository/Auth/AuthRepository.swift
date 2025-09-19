//
//  AuthRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/12.
//

import Foundation
import FirebaseAuth

@MainActor
class AuthRepository {
    static let userDataStore = UserDataStore.shared
    
    //create
    
    //check
    static func isSignIn() async {
        if let currentUser = Auth.auth().currentUser {
            if let user = await UserRepository.getUserData(userId: currentUser.uid) {
                userDataStore.userResult = .success(user)
                userDataStore.signInUser = user
            } else {
                userDataStore.userResult = .success(nil)
                userDataStore.signInUser = nil
            }
        } else {
            userDataStore.userResult = .success(nil)
            userDataStore.signInUser = nil
        }
    }
    
    //get
    
    //check
    
    //update
    
    //delete
    
    //observe
}

