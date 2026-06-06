//
//  MyInfoView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct MyInfoView: View {
    @StateObject var myInfoDataStore: MyInfoDataStore = .shared
    
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
        }
        .alert("ユーザーネームを変更", isPresented: $myInfoDataStore.renameUserNameAlertIsPresent) {
            renameUserNameAlertActions()
        } message: {
            Text("新しいユーザーネームを入力してください。")
        }
        .alert("コピー完了", isPresented: $myInfoDataStore.copiedUserIdAlertIsPresent) {
            Button(role: .close) {} label: {
                Text("OK")
            }
        } message: {
            Text("ユーザーIDをクリップボードにコピーしました。")
        }
        .navigationTitle("マイページ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            UserRepository.observeMyUserData()
        }
    }
    @ViewBuilder
    func renameUserNameAlertActions() -> some View {
        TextField("ユーザーネームを入力", text: $myInfoDataStore.newUserName)
        Button(role: .cancel) {
            myInfoDataStore.newUserName = ""
        } label: {
            Text("キャンセル")
        }
        Button(role: .confirm) {
            Task { await UserRepository.updateUserName(newName: myInfoDataStore.newUserName) }
        } label: {
            Text("変更")
        }
    }
}

#Preview {
    MyInfoView()
}
