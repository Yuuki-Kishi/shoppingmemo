//
//  ParticipantView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI

struct ParticipantView: View {
    @ObservedObject var userDataStore: UserDataStore
    @ObservedObject var participantDataStore: ParticipantDataStore
    @ObservedObject var pathDataStore: PathDataStore
    
    @State private var addParticipantAlertIsPresented: Bool = false
    @State private var addParticipantByUserIdAlertIsPresented: Bool = false
    @State private var addParticipantUserId: String = ""
    
    var body: some View {
        ZStack {
            List {
                Section(content: {
                    ForEach($participantDataStore.administrators, id: \.userId) { participant in
                        ParticipantViewCell(userDataStore: userDataStore, participant: participant)
                    }
                }, header: {
                    Text("管理者")
                })
                if !participantDataStore.members.isEmpty {
                    Section(content: {
                        ForEach($participantDataStore.members, id: \.userId) { participant in
                            ParticipantViewCell(userDataStore: userDataStore, participant: participant)
                        }
                    }, header: {
                        Text("メンバー")
                    })
                }
                if !participantDataStore.guests.isEmpty {
                    Section(content: {
                        ForEach($participantDataStore.guests, id: \.userId) { participant in
                            ParticipantViewCell(userDataStore: userDataStore, participant: participant)
                        }
                    }, header: {
                        Text("ゲスト")
                    })
                }
            }
            plusButton()
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
    func plusButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    addParticipantAlertIsPresented = true
                }, label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.primary)
                        .font(.system(size: 30))
                        .frame(width: 70, height: 70)
                        .background(Color("AccentColor"))
                        .clipShape(Circle())
                })
                .padding(.trailing, 34)
            }
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
