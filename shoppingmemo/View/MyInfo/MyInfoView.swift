//
//  MyInfoView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct MyInfoView: View {
    @EnvironmentObject private var myInfoDataStore: MyInfoDataStore
    
    var body: some View {
        List {
            Section {
                MyInfoViewCell(itemType: .name)
                MyInfoViewCell(itemType: .email)
                MyInfoViewCell(itemType: .userId)
                MyInfoViewCell(itemType: .QR)
                MyInfoViewCell(itemType: .creationDate)
                MyInfoViewCell(itemType: .lastSignInDate)
                MyInfoViewCell(itemType: .useDays)
            } header: {
                Text("自分の情報")
            }
            Section {
                MyInfoViewCell(itemType: .deleteAccount)
            }
        }
        .navigationTitle("マイページ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            UserRepository.observeMyUserData()
        }
    }
}

#Preview {
    MyInfoView()
}
