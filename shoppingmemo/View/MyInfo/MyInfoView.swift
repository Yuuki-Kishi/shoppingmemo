//
//  MyInfoView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct MyInfoView: View {
    @ObservedObject var userDataStore: UserDataStore
    @ObservedObject var myInfoDataStore: MyInfoDataStore
    
    var body: some View {
        ZStack {
            List {
                Section(content: {
                    MyInfoViewCell(userDataStore: userDataStore, myInfoDataStore: myInfoDataStore, itemType: .name)
                    MyInfoViewCell(userDataStore: userDataStore, myInfoDataStore: myInfoDataStore, itemType: .email)
                    MyInfoViewCell(userDataStore: userDataStore, myInfoDataStore: myInfoDataStore, itemType: .userId)
                    MyInfoViewCell(userDataStore: userDataStore, myInfoDataStore: myInfoDataStore, itemType: .QR)
                    MyInfoViewCell(userDataStore: userDataStore, myInfoDataStore: myInfoDataStore, itemType: .creationDate)
                    MyInfoViewCell(userDataStore: userDataStore, myInfoDataStore: myInfoDataStore, itemType: .lastSignInDate)
                    MyInfoViewCell(userDataStore: userDataStore, myInfoDataStore: myInfoDataStore, itemType: .useDays)
                }, header: {
                    Text("自分の情報")
                })
            }
        }
        .alert("ユーザーネームを変更", isPresented: $myInfoDataStore.renameUserNameAlertIsPresent, actions: {
            renameUserNameAlertActions()
        }, message: {
            Text("新しいユーザーネームを入力してください。")
        })
        .alert("コピー完了", isPresented: $myInfoDataStore.copiedUserIdAlertIsPresent, actions: {
            Button(role: .close, action: {}, label: {
                Text("OK")
            })
        }, message: {
            Text("ユーザーIDをクリップボードにコピーしました。")
        })
        .navigationTitle("マイページ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            UserRepository.observeUserData()
        }
    }
    @ViewBuilder
    func renameUserNameAlertActions() -> some View {
        TextField("ユーザーネームを入力", text: $myInfoDataStore.newUserName)
        Button(role: .cancel, action: {
            myInfoDataStore.newUserName = ""
        }, label: {
            Text("キャンセル")
        })
        Button(role: .confirm, action: {
            Task { await UserRepository.updateUserName(newName: myInfoDataStore.newUserName) }
        }, label: {
            Text("変更")
        })
    }
}

#Preview {
    MyInfoView(userDataStore: .shared, myInfoDataStore: .shared)
}
