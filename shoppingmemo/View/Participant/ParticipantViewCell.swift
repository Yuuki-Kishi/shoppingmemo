//
//  ParticipantViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct ParticipantViewCell: View {
    @Binding var authority: Authority
    @State var userName: String = "----"
    @State var email: String = "----"
    
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
        .onAppear() {
            UserRepository.observeUserName(userId: authority.userId) { userName in
                self.userName = userName ?? "----"
            }
            Task { email = await UserRepository.getUserData(userId: authority.userId)?.email ?? "----" }
        }
    }
    func userNameTextColor() -> Color {
        authority.isMine ? Color.green : Color.primary
    }
}

#Preview {
    ParticipantViewCell(authority: Binding(get: { Authority() }, set: {_ in}))
}
