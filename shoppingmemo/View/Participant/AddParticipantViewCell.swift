//
//  AddParticipantViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/14.
//

import SwiftUI

struct AddParticipantViewCell: View {
    @EnvironmentObject private var participantDataStore: ParticipantDataStore
    private let itemType: ItemTypeEnum
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
                Text(participantDataStore.addUserId ?? "----")
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
                guard let userId = participantDataStore.addUserId else { return }
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
                guard let userId = participantDataStore.addUserId else { return }
                Task {
                    email = await UserRepository.getUserData(userId: userId)?.email ?? "----"
                }
            }
        }
    }
}

#Preview {
    AddParticipantViewCell(itemType: .userId)
}
