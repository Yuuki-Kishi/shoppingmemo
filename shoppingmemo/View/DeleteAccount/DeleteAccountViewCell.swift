//
//  DeleteAccountViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/23.
//

import SwiftUI

struct DeleteAccountViewCell: View {
    private var userId: String
    private let itemType: ItemTypeEnum
    @State private var userName: String = "----"
    @State private var email: String = "----"
    
    enum ItemTypeEnum {
        case userId, userName, email
    }
    
    init(userId: String, itemType: ItemTypeEnum) {
        self.userId = userId
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
        case .userName:
            HStack {
                Text("ユーザネーム")
                Spacer()
                Text(userName)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
            .onAppear() {
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
                    email = await UserRepository.getUserData(userId: userId)?.email ?? "----"
                }
            }
        }
    }
}

#Preview {
    DeleteAccountViewCell(userId: "unknownUserId", itemType: .userId)
}
