//
//  ListsView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/11.
//

import SwiftUI

struct ListsView: View {
    @StateObject var userDataStore: UserDataStore = .shared
    @StateObject var roomDataStore: RoomDataStore = .shared
    @StateObject var listDataStore: ListDataStore = .shared
    @StateObject var pathDataStore: PathDataStore = .shared
    
    @State private var newListNameText: String = ""
    @State private var newRoomNameText: String = ""
    @State private var createNewListAlertIsPresent: Bool = false
    @State private var updateRoomNameAlertIsPresent: Bool = false
    @State private var deleteRoomAlertIsPresent: Bool = false
    
    var body: some View {
        ZStack {
            BoolSwitchView(isEmpty: listDataStore.listArray.isEmpty, isLoading: $listDataStore.isLoading, contentName: "リスト") {
                List {
                    ForEach($listDataStore.listArray, id: \.listId) { $list in
                        ListsViewCell(listDataStore: listDataStore, pathDataStore: pathDataStore, list: $list)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                DeleteButton {
                                    listDataStore.selectedList = list
                                    Task { await CustomListRepository.deleteList() }
                                }
                            }
                    }
                    .onMove(perform: move)
                }
                .listRowSpacing(35)
            }
            PlusButton() {
                newListNameText = ""
                createNewListAlertIsPresent = true
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
        .alert("リストを追加", isPresented: $createNewListAlertIsPresent) {
            createNewListAlertActions()
        } message: {
            Text("追加するリストの名前を入力してください。")
        }
        .alert("ルーム名を変更", isPresented: $updateRoomNameAlertIsPresent) {
            updateRoomNameAlertActions()
        } message: {
            Text("新しく設定するルーム名を入力してください。")
        }
        .alert("本当に\(roomDataStore.selectedRoom?.roomName ?? "このルーム")を削除しますか？", isPresented: $deleteRoomAlertIsPresent) {
            deleteRoomAlertActions()
        } message: {
            Text("このルームに含まれる全てのリスト、メモも削除されます。\nこの操作は取り消すことができません。")
        }
        .navigationTitle(roomDataStore.selectedRoom?.roomName ?? "不明なルーム")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            listDataStore.isLoading = true
            CustomListRepository.clearLists()
            CustomListRepository.observeLists() { listDataStore.isLoading = false }
        }
    }
    func move(fromSources: IndexSet, toDestination: Int) {
        Task { await CustomListRepository.updateListOrders(from: fromSources, to: toDestination) }
    }
    func toolBarMenu() -> some View {
        Menu {
            Button {
                newRoomNameText = roomDataStore.selectedRoom?.roomName ?? ""
                updateRoomNameAlertIsPresent = true
            } label: {
                Label("ルーム名を変更", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            }
            Button {
                pathDataStore.navigationPath.append(.participant)
            } label: {
                Label("メンバーリスト", systemImage: "person.2")
            }
            Menu {
                Button {
                    CustomListRepository.sortLists(basedOn: .ascending)
                } label: {
                    Label("名前昇順", systemImage: "a.circle")
                }
                Button {
                    CustomListRepository.sortLists(basedOn: .descending)
                } label: {
                    Label("名前降順", systemImage: "z.circle")
                }
                Button {
                    CustomListRepository.sortLists(basedOn: .newest)
                } label: {
                    Label("更新日時", systemImage: "clock")
                }
                Button {
                    CustomListRepository.sortLists(basedOn: .custom)
                } label: {
                    Label("カスタム", systemImage: "hand.point.up")
                }
            } label: {
                Label("並び替え", systemImage: "arrow.up.arrow.down")
            }
            Divider()
            if isAdministrator() {
                Button(role: .destructive) {
                    pathDataStore.navigationPath.append(.participant)
                } label: {
                    Label("管理者権限を譲渡", systemImage: "person.line.dotted.person")
                }
            }
            Button(role: .destructive) {
                deleteRoomAlertIsPresent = true
            } label: {
                Label("ルーム削除", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    @ViewBuilder
    func createNewListAlertActions() -> some View {
        TextField("リストの名前を入力", text: $newListNameText)
        Button(role: .cancel) {
            newListNameText = ""
        } label: {
            Text("キャンセル")
        }
        Button {
            Task { await CustomListRepository.createList(listName: newListNameText) }
        } label: {
            Text("追加")
        }
    }
    @ViewBuilder
    func updateRoomNameAlertActions() -> some View {
        TextField("新しいルーム名を入力", text: $newRoomNameText)
        Button(role: .cancel) {
            newRoomNameText = roomDataStore.selectedRoom?.roomName ?? ""
        } label: {
            Text("キャンセル")
        }
        Button(role: .confirm) {
            Task { await RoomRepository.updateRoomName(newName: newRoomNameText) }
        } label: {
            Text("変更")
        }
    }
    @ViewBuilder
    func deleteRoomAlertActions() -> some View {
        Button(role: .cancel) {} label: {
            Text("キャンセル")
        }
        Button(role: .destructive) {
            listDataStore.isLoading = true
            Task { await RoomRepository.deleteRoom() }
        } label: {
            Text("削除")
        }
    }
    func isAdministrator() -> Bool {
        guard let myUserId = userDataStore.signInUser?.userId else { return false }
        guard let authorities = roomDataStore.selectedRoom?.authorities else { return false }
        guard let myAuthority = authorities.first(where: { $0.userId == myUserId }) else { return false }
        if myAuthority.authority == .administrator { return true }
        return false
    }
}

#Preview {
    ListsView()
}
