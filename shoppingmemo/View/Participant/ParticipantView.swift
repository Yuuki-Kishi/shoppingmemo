//
//  ParticipantView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct ParticipantView: View {
    @EnvironmentObject private var roomDataStore: RoomDataStore
    @StateObject private var participantDataStore: ParticipantDataStore = .shared
    @EnvironmentObject private var pathDataStore: PathDataStore
    @State private var addParticipantAlertIsPresented: Bool = false
    @State private var addParticipantByUserIdAlertIsPresented: Bool = false
    @State private var addUserIdText: String = ""
    
    var body: some View {
        OptionalUnwrapView(optional: roomDataStore.roomArray.selected) { room in
            ZStack {
                List {
                    Section {
                        ForEach(room.authorities.administrators, id: \.userId) { authority in
                            ParticipantViewCell(authority: authority)
                        }
                    } header: {
                        Text("管理者")
                    }
                    BoolSwitchView(isEmpty: room.authorities.members.isEmpty) {
                        Section {
                            ForEach(room.authorities.members, id: \.userId) { authority in
                                ParticipantViewCell(authority: authority)
                            }
                        } header: {
                            Text("メンバー")
                        }
                    } emptyContent: {}
                    BoolSwitchView(isEmpty: room.authorities.guests.isEmpty) {
                        Section {
                            ForEach(room.authorities.guests, id: \.userId) { authority in
                                ParticipantViewCell(authority: authority)
                            }
                        } header: {
                            Text("ゲスト")
                        }
                    } emptyContent: {}
                }
                PlusButton {
                    addParticipantAlertIsPresented = true
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
}

#Preview {
    ParticipantView()
}
