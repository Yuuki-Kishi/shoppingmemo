//
//  ParticipantViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct ParticipantViewCell: View {
    @ObservedObject var userDataStore: UserDataStore
    @Binding var participant: Participant
    
    var body: some View {
        HStack {
            Text(participant.userName ?? "----")
                .lineLimit(1)
                .foregroundStyle(userNameTextColor())
                .frame(alignment: .leading)
            Spacer()
            Text(participant.email ?? "----")
                .lineLimit(1)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .onAppear() {
            ParticipantRepository.observeUserData(userId: participant.userId, authority: participant.authority)
        }
    }
    func userNameTextColor() -> Color {
        guard let myUserId = userDataStore.signInUser?.userId else { return .primary }
        if participant.userId == myUserId {
            return .green
        }
        return .primary
    }
}

#Preview {
    ParticipantViewCell(userDataStore: .shared, participant: Binding(get: { Participant() }, set: {_ in}))
}
