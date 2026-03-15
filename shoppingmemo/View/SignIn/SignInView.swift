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
        GeometryReader { geometry in
            let width = geometry.size.width / 1.5
            let height = geometry.size.height / 4
            VStack {
                Spacer(minLength: 50)
                Image("Icon")
                    .resizable()
                    .frame(width: height, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: height / 10))
                Spacer(minLength: height)
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal), action: Google.handleSignInButton)
                    .frame(width:  width)
                    .padding(.bottom, 30)
                SignInWithAppleButton(.signIn) { request in
                    Apple.shared.signInWithApple(request: request)
                } onCompletion: { authResults in
                    Apple.shared.login(authRequest: authResults)
                }
                .signInWithAppleButtonStyle(.whiteOutline)
                .frame(width: width, height: 40)
                Spacer()
                HStack {
                    Spacer()
                    Text(AppVersion())
                }
            }
        }
    }
    func AppVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return String("Version: ") + version + "  "
    }
}

#Preview {
    SignInView()
}
