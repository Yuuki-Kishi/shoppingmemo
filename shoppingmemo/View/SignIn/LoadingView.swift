//
//  LoadingView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/11.
//

import SwiftUI

struct LoadingView: View {
    let iconHeight = UIScreen.main.bounds.height / 4
    
    var body: some View {
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
    }
    func AppVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return String("Version: ") + version + String("  ")
    }
}

#Preview {
    LoadingView()
}
