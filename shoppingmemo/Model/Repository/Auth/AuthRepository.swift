//
//  AuthRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/12.
//

import Foundation
import FirebaseAuth

class AuthRepository {
    //check
    @MainActor
    static func checkSignIn() {
        //MARK: Tentative
        if let currentUserId = Auth.auth().currentUser?.uid {
            UserDataStore.shared.userResult = .success(User())
            UserDataStore.shared.signInUser = User()
        } else {
            UserDataStore.shared.userResult = .success(nil)
            UserDataStore.shared.signInUser = nil
        }
    }
}

