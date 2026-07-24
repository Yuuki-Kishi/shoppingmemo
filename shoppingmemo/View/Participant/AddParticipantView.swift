//
//  AddParticipantView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/14.
//

import SwiftUI

struct AddParticipantView: View {
    @EnvironmentObject private var participantDataStore: ParticipantDataStore
    @State private var isEmpty: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            BoolSwitchView(isEmpty: isEmpty, isLoading: participantDataStore.isLoading) {
                List {
                    Section {
                        AddParticipantViewCell(itemType: .userId)
                        AddParticipantViewCell(itemType: .userName)
                        AddParticipantViewCell(itemType: .email)
                    } header: {
                        Text("AddParticipantView.List.Section.header.Text")
                    }
                }
                VStack {
                    Button {
                        guard let userId = participantDataStore.addUserId else { return }
                        Task {
                            await RoomRepository.addAuthority(userId: userId)
                            NavigationRepository.removeViews(dest: .participant)
                        }
                    } label: {
                        Text("AddParticipantView.addParticipantButton.Text")
                            .frame(width: geometry.size.width * 0.6, height: 40)
                    }
                    .foregroundStyle(.primary)
                    .background(Color.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    Button {
                        NavigationRepository.removeViews(dest: .participant)
                    } label: {
                        Text("AddParticipantView.cancelButton.Text")
                            .frame(width: geometry.size.width * 0.6, height: 30)
                    }
                    .foregroundStyle(.primary)
                }
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * 4 / 5
                )
            } emptyContent: {
                ZStack {
                    Text("AddParticipantView.emptyContent.Text")
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 2
                        )
                    Button {
                        NavigationRepository.removeViews(dest: .participant)
                    } label: {
                        Text("AddParticipantView.emptyContent.Button.Text")
                            .frame(width: geometry.size.width * 0.6, height: 30)
                    }
                    .foregroundStyle(.primary)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 4 / 5
                    )
                }
            }
        }
        .navigationTitle("AddParticipantView.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .onAppear() {
            participantDataStore.isLoading = true
            guard let userId = participantDataStore.addUserId else {
                participantDataStore.isLoading = false
                return
            }
            Task {
                isEmpty = await !UserRepository.isExist(userId: userId)
                participantDataStore.isLoading = false
            }
        }
    }
}

#Preview {
    AddParticipantView()
}
