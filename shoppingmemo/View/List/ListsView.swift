//
//  ListsView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/11.
//

import SwiftUI

struct ListsView: View {
    @EnvironmentObject private var userDataStore: UserDataStore
    @EnvironmentObject private var roomDataStore: RoomDataStore
    @EnvironmentObject private var listDataStore: ListDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    @State private var newListNameText: String = ""
    @State private var newRoomNameText: String = ""
    @State private var createNewListAlertIsPresent: Bool = false
    @State private var updateRoomNameAlertIsPresent: Bool = false
    @State private var deleteRoomAlertIsPresent: Bool = false
    
    var body: some View {
        ZStack {
            BoolSwitchView(isEmpty: listDataStore.listArray.isEmpty, isLoading: listDataStore.isLoading) {
                List {
                    ForEach(listDataStore.listArray, id: \.listId) { list in
                        ListsViewCell(list: list)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                DeleteButton {
                                    listDataStore.selectedListId = list.listId
                                    Task { await CustomListRepository.deleteList() }
                                }
                            }
                    }
                    .onMove(perform: move)
                }
                .listRowSpacing(35)
            } emptyContent: {
                Text("リストがありません")
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
        .alert("本当に\(roomDataStore.roomArray.selected?.roomName ?? "このルーム")を削除しますか？", isPresented: $deleteRoomAlertIsPresent) {
            deleteRoomAlertActions()
        } message: {
            Text("このルームに含まれる全てのリスト、メモも削除されます。\nこの操作は取り消すことができません。")
        }
        .navigationTitle(roomDataStore.roomArray.selected?.roomName ?? "不明なルーム")
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
                newRoomNameText = roomDataStore.roomArray.selected?.roomName ?? ""
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
                    ToggleLabel(title: "タイトル昇順", systemImage: "a.circle") {
                        listDataStore.listSort == .ascending
                    }
                }
                Button {
                    CustomListRepository.sortLists(basedOn: .descending)
                } label: {
                    ToggleLabel(title: "タイトル降順", systemImage: "z.circle") {
                        listDataStore.listSort == .descending
                    }
                }
                Button {
                    CustomListRepository.sortLists(basedOn: .newest)
                } label: {
                    ToggleLabel(title: "更新日時", systemImage: "clock") {
                        listDataStore.listSort == .newest
                    }
                }
                Button {
                    CustomListRepository.sortLists(basedOn: .custom)
                } label: {
                    ToggleLabel(title: "カスタム", systemImage: "hand.point.up") {
                        listDataStore.listSort == .custom
                    }
                }
            } label: {
                Label("並び替え", systemImage: "arrow.up.arrow.down")
            }
            Divider()
            if isAdministrator() {
                Button(role: .destructive) {
                    
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
            newRoomNameText = roomDataStore.roomArray.selected?.roomName ?? ""
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
        guard let authorities = roomDataStore.roomArray.selected?.authorities else { return false }
        guard let myAuthority = authorities.first(where: { $0.userId == myUserId }) else { return false }
        if myAuthority.authority == .administrator { return true }
        return false
    }
}

#Preview {
    ListsView()
}
