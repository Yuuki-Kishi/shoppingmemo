//
//  SignInView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/04.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct SignInView: View {
    var body: some View {
        VStack {
            Spacer(minLength: 50)
            Image("Icon")
                .resizable()
                .frame(width: UIScreen.main.bounds.height / 4, height: UIScreen.main.bounds.height / 4)
                .clipShape(RoundedRectangle(cornerRadius: UIScreen.main.bounds.height / 4 * 0.1675))
            Spacer(minLength: UIScreen.main.bounds.height / 4)
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal), action: Google.handleSignInButton)
                .frame(width: UIScreen.main.bounds.width / 1.5)
                .padding(.bottom, 30)
            SignInWithAppleButton(.signIn) { request in
                Apple.shared.signInWithApple(request: request)
            } onCompletion: { authResults in
                Apple.shared.login(authRequest: authResults)
            }
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(width: UIScreen.main.bounds.width / 1.5, height: 40)
            Spacer()
            HStack {
                Spacer()
                Text(AppVersion())
            }
        }
        .padding()
    }
    func AppVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return String("Version: ") + version
    }
}

#Preview {
    SignInView()
}
