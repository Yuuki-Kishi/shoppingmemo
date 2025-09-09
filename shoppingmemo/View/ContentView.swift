//
//  ContentView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var userDataStore = UserDataStore.shared
    
    var body: some View {
        Group {
            if userDataStore.userResult == nil {
                let iconHeight = UIScreen.main.bounds.height / 4
                VStack {
                    Spacer()
                    Image("Icon")
                        .resizable()
                        .frame(width: iconHeight, height: iconHeight)
                        .clipShape(RoundedRectangle(cornerRadius: iconHeight * 0.1675))
                    Spacer()
                    Text("ログインデータを確認中...")
                    Spacer()
                    HStack {
                        Spacer()
                        Text(AppVersion())
                    }
                }
            } else {
                if userDataStore.signInUser == nil {
                    SignInView()
                } else {
                    
                }
            }
        }
        .onAppear() {
            Task {
//                await AuthRepository.isSignIn()
            }
        }
    }
    func AppVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return String("Version: ") + version + String("  ")
    }
}

#Preview {
    ContentView()
}
