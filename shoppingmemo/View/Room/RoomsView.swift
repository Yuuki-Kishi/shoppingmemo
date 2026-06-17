//
//  RoomView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/09.
//

import SwiftUI

struct RoomsView: View {
    @EnvironmentObject private var roomDataStore: RoomDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    @State private var newRoomNameText: String = ""
    @State private var newRoomCreateAlertIsPresented: Bool = false
    @State private var signOutAlertIsPresented: Bool = false
    
    var body: some View {
        NavigationStack(path: $pathDataStore.navigationPath) {
            ZStack {
                BoolSwitchView(isEmpty: roomDataStore.roomArray.isEmpty, isLoading: roomDataStore.isLoading) {
                    List(roomDataStore.roomArray, id: \.id) { room in
                        RoomsViewCell(room: room)
                    }
                    .listRowSpacing(35)
                } emptyContent: {
                    Text("ルームがありません")
                }
                PlusButton() {
                    newRoomNameText = ""
                    newRoomCreateAlertIsPresented = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HelpButton()
                }
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItem(placement: .topBarTrailing) {
                    toolBarMenu()
                }
            }
            .alert("ルームを新規作成", isPresented: $newRoomCreateAlertIsPresented) {
                newRoomCreateAlertActions()
            } message: {
                Text("新規作成するルームの名前を入力してください。")
            }
            .alert("本当にサインアウトしますか？", isPresented: $signOutAlertIsPresented) {
                signOutAlertActions()
            } message: {
                Text("サインアウトすると、再度利用する際にサインインが必要になります。")
            }
            .navigationDestination(for: PathDataStore.path.self) { path in
                destination(path: path)
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
                roomDataStore.isLoading = true
                RoomRepository.observeRooms() {
                    roomDataStore.isLoading = false
                }
            }
        }
    }
    @ViewBuilder
    func destination(path: PathDataStore.path) -> some View {
        switch path {
        case .lists:
            ListsView()
        case .memos:
            MemosView()
        case .image:
            ImageView()
        case .myInfo:
            MyInfoView()
        case .setting:
            EmptyView()
        case .instruction:
            EmptyView()
        case .noticeList:
            EmptyView()
        case .notice:
            EmptyView()
        case .participant:
            ParticipantView()
        case .QRreader:
            QRCodeReaderView()
        case .addParicipant:
            AddParticipantView()
        }
    }
    func toolBarMenu() -> some View {
        Menu {
            Button {
                pathDataStore.navigationPath.append(.myInfo)
            } label: {
                Label("マイページ", systemImage: "info.circle")
            }
            Button {
                
            } label: {
                Label("設定", systemImage: "gear")
            }
            Button {
                
            } label: {
                Label("通知一覧", systemImage: "bell")
            }
            Divider()
            Button(role: .destructive) {
                signOutAlertIsPresented = true
            } label: {
                Text("サインアウト")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(Color.primary)
        }
    }
    @ViewBuilder
    func newRoomCreateAlertActions() -> some View {
        TextField("ルームの名前を入力", text: $newRoomNameText)
        Button(role: .cancel) {} label: {
            Text("キャンセル")
        }
        Button(role: .confirm) {
            Task { await RoomRepository.createRoom(roomName: newRoomNameText) }
        } label: {
            Text("作成")
        }
    }
    @ViewBuilder
    func signOutAlertActions() -> some View {
        Button(role: .cancel) {} label: {
            Text("キャンセル")
        }
        Button(role: .destructive) {
            Task { await AuthRepository.signOut() }
        } label: {
            Text("サインアウト")
        }
    }
}

#Preview {
    RoomsView()
}
