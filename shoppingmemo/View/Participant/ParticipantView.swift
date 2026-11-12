//
//  ParticipantView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct ParticipantView: View {
    @EnvironmentObject private var roomDataStore: RoomDataStore
    @EnvironmentObject private var participantDataStore: ParticipantDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    @State private var addParticipantAlertIsPresented: Bool = false
    @State private var addParticipantByUserIdAlertIsPresented: Bool = false
    @State private var leaveGroupAlertIsPresented: Bool = false
    @State private var addUserIdText: String = ""
    
    var body: some View {
        OptionalUnwrapView(optional: roomDataStore.roomArray.selected) { room in
            ZStack {
                List {
                    Section {
                        ForEach(room.authorities.administrators, id: \.self) { userId in
                            ParticipantViewCell(userId: userId)
                        }
                    } header: {
                        Text("ParticipantView.List.administratorSection.header.Text")
                    }
                    BoolSwitchView(isEmpty: room.authorities.editors.isEmpty) {
                        Section {
                            ForEach(room.authorities.editors, id: \.self) { userId in
                                if room.authorities.myAuthority == .administrator {
                                    ParticipantViewCell(userId: userId)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            DeleteIconButton {
                                                Task { await RoomRepository.removeAuthority(userId: userId, roomId: room.roomId) }
                                            }
                                        }
                                } else {
                                    ParticipantViewCell(userId: userId)
                                }
                            }
                        } header: {
                            Text("ParticipantView.List.memberSection.header.Text")
                        }
                    } emptyContent: {}
                    BoolSwitchView(isEmpty: room.authorities.guests.isEmpty) {
                        Section {
                            ForEach(room.authorities.guests, id: \.self) { userId in
                                ParticipantViewCell(userId: userId)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        DeleteIconButton {
                                            Task { await RoomRepository.removeAuthority(userId: userId, roomId: room.roomId) }
                                        }
                                    }
                            }
                        } header: {
                            Text("ParticipantView.List.guestSection.header.Text")
                        }
                    } emptyContent: {}
                }
                if room.authorities.myAuthority == .administrator {
                    PlusButton {
                        addParticipantAlertIsPresented = true
                    }
                } else {
                    LeaveButton {
                        leaveGroupAlertIsPresented = true
                    }
                }
            }
        } nilContent: {
            Text("ParticipantView.nilContent.Text")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HelpButton()
            }
        }
        .alert("ParticipantView.addParticipantAlert.title", isPresented: $addParticipantAlertIsPresented) {
            addParticipantAlertActions()
        } message: {
            Text("ParticipantView.addParticipantAlert.message")
        }
        .alert("ParticipantView.addParticipantsByUserIdAlert.title", isPresented: $addParticipantByUserIdAlertIsPresented) {
            addParicipantByUserIdAlertActions()
        } message: {
            Text("ParticipantView.addParticipantsByUserIdAlert.message")
        }
        .alert("ParticipantView.leaveGroupAlert.title", isPresented: $leaveGroupAlertIsPresented) {
            leaveGroupAlertActions()
        } message: {
            Text("ParticipantView.leaveGroupAlert.message")
        }
        .navigationTitle("ParticipantView.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
    @ViewBuilder
    func addParticipantAlertActions() -> some View {
        CancelButton()
        Button(role: .confirm) {
            pathDataStore.navigationPath.append(.QRreader)
        } label: {
            Text("ParticipantView.addParticipantAlertActions.QRButton.Text")
        }
        Button(role: .confirm) {
            addParticipantByUserIdAlertIsPresented = true
        } label: {
            Text("ParticipantView.addParticipantAlertActions.userIdButton.Text")
        }
    }
    @ViewBuilder
    func addParicipantByUserIdAlertActions() -> some View {
        CancelButton {
            addUserIdText = ""
        }
        TextField("ParticipantView.addParticipantByUserIdAlertActions.TextField.title", text: $addUserIdText)
        Button(role: .confirm) {
            participantDataStore.addUserId = addUserIdText
            addUserIdText = ""
            pathDataStore.navigationPath.append(.addParicipant)
        } label: {
            Text("ParticipantView.addParticipantByUserIdAlertActions.Button.Text")
        }
    }
    @ViewBuilder
    func leaveGroupAlertActions() -> some View {
        CancelButton()
        Button(role: .destructive) {
            Task {
                guard let roomId = roomDataStore.roomArray.selected?.roomId else { return }
                await RoomRepository.removeMyAuthority(roomId: roomId)
                NavigationRepository.removeAllViews()
            }
        } label: {
            Text("ParticipantView.leaveGroupAlertActions.Button.Text")
        }
    }
}

#Preview {
    ParticipantView()
}
