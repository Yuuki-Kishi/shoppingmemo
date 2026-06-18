//
//  ParticipantViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct ParticipantViewCell: View {
    @EnvironmentObject private var userDataStore: UserDataStore
    @EnvironmentObject private var roomDataStore: RoomDataStore
    private let userId: String
    @State private var userName: String = "----"
    @State private var email: String = "----"
    @State private var transferAuthorityAlertIsPresented: Bool = false
    
    init(userId: String) {
        self.userId = userId
    }
    
    var body: some View {
        HStack {
            Text(userName)
                .lineLimit(1)
                .foregroundStyle(userNameTextColor())
                .frame(height: 30, alignment: .leading)
            Spacer()
            Text(email)
                .lineLimit(1)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .task {
            email = await UserRepository.getUserData(userId: userId)?.email ?? "----"
        }
        .onTapGesture {
            guard roomDataStore.roomArray.selected?.authorities.myAuthority == .administrator else { return }
            guard userDataStore.signInUser?.userId != userId else { return }
            transferAuthorityAlertIsPresented = true
        }
        .alert("管理者権限を譲渡しますか？", isPresented: $transferAuthorityAlertIsPresented) {
            Button(role: .cancel) {} label: {
                Text("キャンセル")
            }
            Button(role: .destructive) {
                Task { await RoomRepository.transferAuthority(newAdministratorUserId: userId) }
            } label: {
                Text("譲渡")
            }
        } message: {
            Text("この操作は取り消すことができません。")
        }
        .onAppear() {
            UserRepository.observeUserName(userId: userId) { userName in
                self.userName = userName ?? "----"
            }
        }
    }
    func userNameTextColor() -> Color {
        userId.isMyUserId ? .green : .primary
    }
}

#Preview {
    ParticipantViewCell(userId: "unknownUserId")
}
