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
                Text("MyInfoView.List.Section.header.Text")
            }
            Section {
                MyInfoViewCell(itemType: .deleteAccount)
            }
        }
        .navigationTitle("MyInfoView.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            UserRepository.observeMyUserData()
        }
    }
}

#Preview {
    MyInfoView()
}
