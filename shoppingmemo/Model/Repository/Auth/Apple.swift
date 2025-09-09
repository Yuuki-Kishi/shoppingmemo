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

class Apple: NSObject, ASAuthorizationControllerDelegate {
    static let shared = Apple()
    var currentNonce: String?
    
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
    
    @MainActor
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
            Auth.auth().signIn(with: credential) { result, error in
                if result?.user != nil{
                    guard let userId = result?.user.uid else { return }
                    guard let creationDate = result?.user.metadata.creationDate else { return }
//                    UserDataStore.shared.userResult = .success(User())
//                    UserDataStore.shared.signInUser = User()
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
