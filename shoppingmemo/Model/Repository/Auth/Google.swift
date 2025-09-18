//
//  Google.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/04.
//

import Foundation
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

@MainActor
class Google {
    static let userDataStore = UserDataStore.shared
    
    static func handleSignInButton() {
        guard let clientID: String = FirebaseApp.app()?.options.clientID else { return }
        let config:GIDConfiguration = GIDConfiguration(clientID: clientID)
        let windowScene:UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController:UIViewController? = windowScene?.windows.first!.rootViewController!
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController!) { result, error in
            guard error == nil else {
                print("GIDSignInError: \(error!.localizedDescription)")
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: user.accessToken.tokenString)
            self.login(credential: credential)
        }
    }
    
    static func reauthenticateAndDeleteUser() {
        guard let clientID: String = FirebaseApp.app()?.options.clientID else { return }
        let config:GIDConfiguration = GIDConfiguration(clientID: clientID)
        let windowScene:UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController:UIViewController? = windowScene?.windows.first!.rootViewController!
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController!) { result, error in
            guard error == nil else {
                print("GIDSignInError: \(error!.localizedDescription)")
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: user.accessToken.tokenString)
            Auth.auth().currentUser?.reauthenticate(with: credential) { _, error  in
                if let error = error {
                    print("reauthenticateError: \(error.localizedDescription)")
                    return
                }
//                AuthRepository.deleteUser()
            }
        }
    }
    
    static func login(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            Task {
                if let error = error {
                    print("SignInError: \(error.localizedDescription)")
                    return
                }
                guard let userId = authResult?.user.uid else { return }
                guard let creationTime = authResult?.user.metadata.creationDate else { return }
                let AppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
                guard let email = authResult?.user.email else { return }
                let iOSVersion = UIDevice.current.systemVersion
                let isExist = await UserRepository.isExist(userId: userId)
                if isExist {
                    let notExistPropatyKeys = await UserRepository.notExistPropaties(userId: userId)
                    var notExistPropaties: [String: Any] = [:]
                    let formatter = ISO8601DateFormatter()
                    let creationTimeString = formatter.string(from: creationTime)
                    for notExistPropatyKey in notExistPropatyKeys {
                        if notExistPropatyKey == "creationTime" { notExistPropaties.updateValue(creationTimeString, forKey: notExistPropatyKey) }
                        else if notExistPropatyKey == "currentVersion" { notExistPropaties.updateValue(AppVersion, forKey: notExistPropatyKey) }
                        else if notExistPropatyKey == "email" { notExistPropaties.updateValue(email, forKey: notExistPropatyKey) }
                        else if notExistPropatyKey == "iOSVersion" { notExistPropaties.updateValue(iOSVersion, forKey: notExistPropatyKey) }
                        else if notExistPropatyKey == "noticeCheckedTime" { notExistPropaties.updateValue("2025-01-01T00:00:00Z", forKey: notExistPropatyKey) }
                        else if notExistPropatyKey == "userName" { notExistPropaties.updateValue("未設定", forKey: notExistPropatyKey) }
                    }
                    await UserRepository.addPropaties(userId: userId, propaties: notExistPropaties)
                    guard let user = await UserRepository.getUserData(userId: userId) else { return }
                    userDataStore.userResult = .success(user)
                    userDataStore.signInUser = user
                } else {
                    guard let user = await UserRepository.create(userId: userId, email: email, creationTime: creationTime) else { return }
                    userDataStore.userResult = .success(user)
                    userDataStore.signInUser = user
                }
            }
        }
    }
}
