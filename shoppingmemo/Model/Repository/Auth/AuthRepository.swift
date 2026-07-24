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
            if await UserRepository.isNeedCompensate() {
                await UserRepository.compensatePropaties()
            }
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
    static func getProvider() -> UserDataStore.providerEnum {
        guard let providerID = Auth.auth().currentUser?.providerData.first?.providerID else { return .unknown }
        guard let provider = UserDataStore.providerEnum(rawValue: providerID) else { return .unknown }
        return provider
    }
        
    //update
    
    //delete
    static func signOut() async {
        do {
            try Auth.auth().signOut()
             userDataStore.signInUser = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    static func deleteAccount(success: @escaping () -> Void, failure: @escaping () -> Void) {
        Task {
            do {
                try await Auth.auth().currentUser?.delete()
                success()
            } catch {
                print(error)
                failure()
            }
        }
    }
    
    //observe
}

