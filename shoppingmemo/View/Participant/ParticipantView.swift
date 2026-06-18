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
                        Text("管理者")
                    }
                    BoolSwitchView(isEmpty: room.authorities.members.isEmpty) {
                        Section {
                            ForEach(room.authorities.members, id: \.self) { userId in
                                if room.authorities.myAuthority == .administrator {
                                    ParticipantViewCell(userId: userId)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            DeleteButton {
                                                Task { await RoomRepository.removeAuthority(userId: userId, roomId: room.roomId) }
                                            }
                                        }
                                } else {
                                    ParticipantViewCell(userId: userId)
                                }
                            }
                        } header: {
                            Text("メンバー")
                        }
                    } emptyContent: {}
                    BoolSwitchView(isEmpty: room.authorities.guests.isEmpty) {
                        Section {
                            ForEach(room.authorities.guests, id: \.self) { userId in
                                ParticipantViewCell(userId: userId)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        DeleteButton {
                                            Task { await RoomRepository.removeAuthority(userId: userId, roomId: room.roomId) }
                                        }
                                    }
                            }
                        } header: {
                            Text("招待中")
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
            Text("ルームを選択してください")
        }
        .alert("メンバーを追加", isPresented: $addParticipantAlertIsPresented) {
            addParticipantAlertActions()
        } message: {
            Text("メンバーを追加する方法を選択してください。")
        }
        .alert("ユーザーIDで追加", isPresented: $addParticipantByUserIdAlertIsPresented) {
            addParicipantByUserIdAlertActions()
        } message: {
            Text("追加するメンバーのユーザーIDを入力してください。")
        }
        .alert("本当に脱退しますか？", isPresented: $leaveGroupAlertIsPresented) {
            leaveGroupAlertActions()
        } message: {
            Text("この操作は取り消すことができません。")
        }
        .navigationTitle("メンバーリスト")
        .navigationBarTitleDisplayMode(.inline)
    }
    @ViewBuilder
    func addParticipantAlertActions() -> some View {
        Button(role: .confirm) {
            pathDataStore.navigationPath.append(.QRreader)
        } label: {
            Text("QRコード")
        }
        Button(role: .confirm) {
            addParticipantByUserIdAlertIsPresented = true
        } label: {
            Text("ユーザーID")
        }
        Button(role: .cancel) {} label: {
            Text("キャンセル")
        }
    }
    @ViewBuilder
    func addParicipantByUserIdAlertActions() -> some View {
        TextField("ユーザーID", text: $addUserIdText)
        Button(role: .confirm) {
            participantDataStore.addUserId = addUserIdText
            addUserIdText = ""
            pathDataStore.navigationPath.append(.addParicipant)
        } label: {
            Text("追加")
        }
        Button(role: .cancel) {
            addUserIdText = ""
        } label: {
            Text("キャンセル")
        }
    }
    @ViewBuilder
    func leaveGroupAlertActions() -> some View {
        Button(role: .cancel) {} label: {
            Text("キャンセル")
        }
        Button(role: .destructive) {
            Task {
                guard let roomId = roomDataStore.roomArray.selected?.roomId else { return }
                await RoomRepository.removeMyAuthority(roomId: roomId)
                NavigationRepository.removeAllViews()
            }
        } label: {
            Text("脱退")
        }
    }
}

#Preview {
    ParticipantView()
}
