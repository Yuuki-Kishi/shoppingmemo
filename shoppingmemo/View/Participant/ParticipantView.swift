//
//  ParticipantView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct ParticipantView: View {
    @StateObject var roomDataStore: RoomDataStore = .shared
    @StateObject var pathDataStore: PathDataStore = .shared
    
    @State private var addParticipantAlertIsPresented: Bool = false
    @State private var addParticipantByUserIdAlertIsPresented: Bool = false
    @State private var addParticipantUserId: String = ""
    
    var body: some View {
        ZStack {
            BoolSwitchView(optional: roomDataStore.selectedRoom) { selectedRoom in
                List {
                    Section {
                        ForEach(selectedRoom.authorities.administrators, id: \.userId) { authority in
                            ParticipantViewCell(authority: authority)
                        }
                    } header: {
                        Text("管理者")
                    }
                    BoolSwitchView(isEmpty: roomDataStore.selectedRoom?.authorities.members.isEmpty) {
                        Section {
                            ForEach($roomDataStore.selectedRoom?.authorities.members, id: \.userId) { authority in
                                ParticipantViewCell(authority: authority)
                            }
                        } header: {
                            Text("メンバー")
                        }
                    }
                    BoolSwitchView(isEmpty: roomDataStore.selectedRoom?.authorities.guests.isEmpty) {
                        Section {
                            ForEach($roomDataStore.selectedRoom?.authorities.guests, id: \.userId) { authority in
                                ParticipantViewCell(authority: authority)
                            }
                        } header: {
                            Text("ゲスト")
                        }
                    }
                }
            }
            List {
                Section {
                    ForEach($roomDataStore.selectedRoom?.authorities.administrators, id: \.userId) { authority in
                        ParticipantViewCell(authority: authority)
                    }
                } header: {
                    Text("管理者")
                }
                BoolSwitchView(isEmpty: roomDataStore.selectedRoom?.authorities.members.isEmpty) {
                    Section {
                        ForEach($roomDataStore.selectedRoom?.authorities.members, id: \.userId) { authority in
                            ParticipantViewCell(authority: authority)
                        }
                    } header: {
                        Text("メンバー")
                    }
                }
                BoolSwitchView(isEmpty: roomDataStore.selectedRoom?.authorities.guests.isEmpty) {
                    Section {
                        ForEach($roomDataStore.selectedRoom?.authorities.guests, id: \.userId) { authority in
                            ParticipantViewCell(authority: authority)
                        }
                    } header: {
                        Text("ゲスト")
                    }
                }
            }
            PlusButton {
                addParticipantAlertIsPresented = true
            }
        }
        .alert("メンバーを追加", isPresented: $addParticipantAlertIsPresented, actions: {
            addParticipantAlertActions()
        }, message: {
            Text("メンバーを追加する方法を選択してください。")
        })
        .alert("ユーザーIDで追加", isPresented: $addParticipantByUserIdAlertIsPresented, actions: {
            addParicipantByUserIdAlertActions()
        }, message: {
            Text("追加するメンバーのユーザーIDを入力してください。")
        })
        .onAppear() {
            ParticipantRepository.observeRoomParticipants()
        }
    }
    @ViewBuilder
    func addParticipantAlertActions() -> some View {
        Button(role: .confirm, action: {
            pathDataStore.navigationPath.append(.QRreader)
        }, label: {
            Text("QRコード")
        })
        Button(role: .confirm, action: {
            addParticipantByUserIdAlertIsPresented = true
        }, label: {
            Text("ユーザーID")
        })
        Button(role: .cancel, action: {}, label: {
            Text("キャンセル")
        })
    }
    @ViewBuilder
    func addParicipantByUserIdAlertActions() -> some View {
        TextField("ユーザーID", text: $addParticipantUserId)
        Button(role: .confirm, action: {
            pathDataStore.navigationPath.append(.addParicipant)
        }, label: {
            Text("追加")
        })
        Button(role: .cancel, action: {
            addParticipantUserId = ""
        }, label: {
            Text("キャンセル")
        })
    }
}

#Preview {
    ParticipantView(userDataStore: .shared, participantDataStore: .shared, pathDataStore: .shared)
}
