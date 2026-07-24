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
                    Text("RoomsView.emptyContent.Text")
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
            .alert("RoomsView.newRoomCreateAlert.title", isPresented: $newRoomCreateAlertIsPresented) {
                newRoomCreateAlertActions()
            } message: {
                Text("RoomsView.newRoomCreateAlert.message")
            }
            .alert("RoomsView.signOutAlert.title", isPresented: $signOutAlertIsPresented) {
                signOutAlertActions()
            } message: {
                Text("RoomsView.signOutAlert.message")
            }
            .navigationDestination(for: PathDataStore.path.self) { path in
                destination(path: path)
            }
            .navigationTitle("RoomsView.navigationTitle")
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
            NoticeListView()
        case .notice:
            NoticeView()
        case .participant:
            ParticipantView()
        case .QRreader:
            QRCodeReaderView()
        case .addParicipant:
            AddParticipantView()
        case .deleteAccount:
            DeleteAccountView()
        }
    }
    func toolBarMenu() -> some View {
        Menu {
            Button {
                pathDataStore.navigationPath.append(.myInfo)
            } label: {
                Label("RoomsView.toolBarMenu.myInfo.Label.title", systemImage: "info.circle")
            }
//            Button {
//                
//            } label: {
//                Label("設定", systemImage: "gear")
//            }
            Button {
                pathDataStore.navigationPath.append(.noticeList)
            } label: {
                Label("RoomsView.toolBarMenu.notice.Label.title", systemImage: "bell")
            }
            Divider()
            Button(role: .destructive) {
                signOutAlertIsPresented = true
            } label: {
                Text("RoomsView.toolBarMenu.signOut.Text")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(Color.primary)
        }
    }
    @ViewBuilder
    func newRoomCreateAlertActions() -> some View {
        TextField("RoomsView.newRoomCreateAlert.TextField.title", text: $newRoomNameText)
        CancelButton()
        Button(role: .confirm) {
            Task { await RoomRepository.createRoom(roomName: newRoomNameText) }
        } label: {
            Text("RoomsView.newRoomCreateAlert.Button.Text")
        }
    }
    @ViewBuilder
    func signOutAlertActions() -> some View {
        CancelButton()
        Button(role: .destructive) {
            Task { await AuthRepository.signOut() }
        } label: {
            Text("RoomsView.signOutAlert.Button.Text")
        }
    }
}

#Preview {
    RoomsView()
}
