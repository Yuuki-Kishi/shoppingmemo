//
//  DeleteAccountViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/23.
//

import SwiftUI

struct DeleteAccountViewCell: View {
    @EnvironmentObject private var userDataStore: UserDataStore
    private let itemType: ItemTypeEnum
    @State private var userId: String = "----"
    @State private var userName: String = "----"
    @State private var email: String = "----"
    
    enum ItemTypeEnum {
        case userId, userName, email
    }
    
    init(itemType: ItemTypeEnum) {
        self.itemType = itemType
    }
    
    var body: some View {
        switch itemType {
        case .userId:
            HStack {
                Text("ユーザID")
                Spacer()
                Text(userId)
                    .font(.system(size: 15))
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
            .onAppear() {
                guard let userId = userDataStore.signInUser?.userId else { return }
                self.userId = userId
            }
        case .userName:
            HStack {
                Text("ユーザネーム")
                Spacer()
                Text(userName)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
            .onAppear() {
                guard let userId = userDataStore.signInUser?.userId else { return }
                UserRepository.observeUserName(userId: userId) { userName in
                    self.userName = userName ?? "----"
                }
            }
        case .email:
            HStack {
                Text("メールアドレス")
                Spacer()
                Text(email)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
            .onAppear() {
                Task {
                    guard let userId = userDataStore.signInUser?.userId else { return }
                    email = await UserRepository.getUserData(userId: userId)?.email ?? "----"
                }
            }
        }
    }
}

#Preview {
    DeleteAccountViewCell(itemType: .userId)
}
