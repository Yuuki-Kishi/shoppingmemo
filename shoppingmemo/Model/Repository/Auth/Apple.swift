//
//  Apple.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/04.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import CryptoKit

@MainActor
class Apple: NSObject, ASAuthorizationControllerDelegate {
    static let shared = Apple()
    var currentNonce: String?
    static let userDataStore = UserDataStore.shared
    
    func signInWithApple(request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email,.fullName]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func login(authRequest: Result<ASAuthorization, any Error>) {
        switch authRequest {
        case .success(let authResults):
            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
            Auth.auth().signIn(with: credential) { authResult, error in
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
                        Apple.userDataStore.userResult = .success(user)
                        Apple.userDataStore.signInUser = user
                    } else {
                        guard let user = await UserRepository.create(userId: userId, email: email, creationTime: creationTime) else { return }
                        Apple.userDataStore.userResult = .success(user)
                        Apple.userDataStore.signInUser = user
                    }
                }
            }
            
        case .failure(let error):
            print("Authentication failed: \(error.localizedDescription)")
            break
        }
    }
    
    static func reauthenticateAndDeleteUser() {
        guard let appleId = Auth.auth().currentUser?.providerData.first(where: { $0.providerID == "apple.com" })?.uid else { return }
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.user = appleId
        Apple.shared.signInWithApple(request: request)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = shared
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
            return
        }
        
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
            return
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
        Auth.auth().currentUser?.reauthenticate(with: credential) { result, error in
            if let error = error {
                print("Error reauthenticating with Apple: \(error)")
                return
            }
//            AuthRepository.deleteUser()
        }
    }
}
