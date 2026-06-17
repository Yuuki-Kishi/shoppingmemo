//
//  ParticipantViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct ParticipantViewCell: View {
    private let userId: String
    @State private var userName: String = "----"
    @State private var email: String = "----"
    
    init(userId: String) {
        self.userId = userId
    }
    
    var body: some View {
        HStack {
            Text(userName)
                .lineLimit(1)
                .foregroundStyle(userNameTextColor())
                .frame(alignment: .leading)
            Spacer()
            Text(email)
                .lineLimit(1)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .task {
            email = await UserRepository.getUserData(userId: userId)?.email ?? "----"
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
