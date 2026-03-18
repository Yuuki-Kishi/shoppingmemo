//
//  SignInLoadingView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/11.
//

import SwiftUI

struct SignInLoadingView: View {
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height / 4
            VStack {
                Spacer()
                Image("Icon")
                    .resizable()
                    .frame(width: height, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: height / 10))
                Spacer()
                Text("ログインデータを確認中...")
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
        return String("Version: ") + version + String("  ")
    }
}

#Preview {
    SignInLoadingView()
}
