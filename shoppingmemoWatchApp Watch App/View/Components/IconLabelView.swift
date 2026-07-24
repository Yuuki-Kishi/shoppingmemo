//
//  WaitView.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/13.
//

import SwiftUI

struct IconLabelView: View {
    private let iconString: String
    private let labelText: LocalizedStringKey
    
    init(iconString: String, labelText: LocalizedStringKey) {
        self.iconString = iconString
        self.labelText = labelText
    }
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: iconString)
                .resizable()
                .foregroundColor(Color.primary)
                .scaledToFit()
                .frame(width: 50, height: 50)
            Text(labelText)
            Spacer()
            HStack {
                Spacer()
                Text(appVersionString())
            }
        }
    }
    func appVersionString() -> String {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "Version: ----" }
        return "Version: " + appVersion
    }
}

#Preview {
    IconLabelView(iconString: "iphone.gen3.radiowaves.left.and.right", labelText: "接続準備完了")
}
