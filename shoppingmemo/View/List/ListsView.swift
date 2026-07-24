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
    @State private var renameRoomNameAlertIsPresent: Bool = false
    @State private var deleteRoomAlertIsPresent: Bool = false
    
    var body: some View {
        ZStack {
            BoolSwitchView(isEmpty: listDataStore.listArray.isEmpty, isLoading: listDataStore.isLoading) {
                List {
                    ForEach(listDataStore.listArray, id: \.listId) { list in
                        ListsViewCell(list: list)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                DeleteIconButton {
                                    listDataStore.selectedListId = list.listId
                                    Task { await CustomListRepository.deleteList() }
                                }
                            }
                    }
                    .onMove(perform: move)
                }
                .listRowSpacing(35)
            } emptyContent: {
                Text("ListsView.enptyContent.Text")
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
        .alert("ListsView.createNewListAlert.title", isPresented: $createNewListAlertIsPresent) {
            createNewListAlertActions()
        } message: {
            Text("ListsView.createNewListAlert.message")
        }
        .alert("ListsView.renameRoomNameAlert.title", isPresented: $renameRoomNameAlertIsPresent) {
            renameRoomNameAlertActions()
        } message: {
            Text("ListsView.updateRoomNameAlert.message")
        }
        .alert("ListsView.deleteRoomAlert.title\(roomDataStore.roomArray.selected?.roomName ?? "ListsView.deleteRoomAlert.unknownRoomName")", isPresented: $deleteRoomAlertIsPresent) {
            deleteRoomAlertActions()
        } message: {
            Text("ListsView.deleteRoomAlert.message")
        }
        .navigationTitle(roomDataStore.roomArray.selected?.roomName ?? "ListsView.navigationTitle.unknownRoomName")
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
                renameRoomNameAlertIsPresent = true
            } label: {
                Label("ListsView.toolBarMenu.renameRoom", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            }
            Button {
                pathDataStore.navigationPath.append(.participant)
            } label: {
                Label("ListsView.toolBarMenu.participant", systemImage: "person.2")
            }
            Menu {
                Button {
                    CustomListRepository.sortLists(basedOn: .ascending)
                } label: {
                    ToggleLabel(title: "ListsView.toolBarMenu.sort.ToggleLabel.A-Z", systemImage: "a.circle") {
                        listDataStore.listSort == .ascending
                    }
                }
                Button {
                    CustomListRepository.sortLists(basedOn: .descending)
                } label: {
                    ToggleLabel(title: "ListsView.toolBarMenu.sort.ToggleLabel.Z-A", systemImage: "z.circle") {
                        listDataStore.listSort == .descending
                    }
                }
                Button {
                    CustomListRepository.sortLists(basedOn: .newest)
                } label: {
                    ToggleLabel(title: "ListsView.toolBarMenu.sort.ToggleLabel.newest", systemImage: "clock") {
                        listDataStore.listSort == .newest
                    }
                }
                Button {
                    CustomListRepository.sortLists(basedOn: .custom)
                } label: {
                    ToggleLabel(title: "ListsView.toolBarMenu.sort.ToggleLabel.custom", systemImage: "hand.point.up") {
                        listDataStore.listSort == .custom
                    }
                }
            } label: {
                Label("ListsView.toolBarMenu.sort.Label.title", systemImage: "arrow.up.arrow.down")
            }
            Divider()
            if roomDataStore.roomArray.selected?.authorities.myAuthority == .administrator {
                Button(role: .destructive) {
                    deleteRoomAlertIsPresent = true
                } label: {
                    Label("ListsView.toolBarMenu.deleteRoom.Label.title", systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    @ViewBuilder
    func createNewListAlertActions() -> some View {
        TextField("ListsView.createNewAlertActions.textField.title", text: $newListNameText)
        CancelButton {
            newListNameText = ""
        }
        Button {
            Task { await CustomListRepository.createList(listName: newListNameText) }
        } label: {
            Text("ListsView.createNewAlertActions.Button.Text")
        }
    }
    @ViewBuilder
    func renameRoomNameAlertActions() -> some View {
        TextField("ListsView.updateRoomNameAlertActions.TextField.title", text: $newRoomNameText)
        CancelButton {
            newRoomNameText = roomDataStore.roomArray.selected?.roomName ?? ""
        }
        Button(role: .confirm) {
            Task { await RoomRepository.updateRoomName(newName: newRoomNameText) }
        } label: {
            Text("ListsView.updateRoomNameAlertActions.Button.Text")
        }
    }
    @ViewBuilder
    func deleteRoomAlertActions() -> some View {
        CancelButton()
        DeleteButton {
            listDataStore.isLoading = true
            Task { await RoomRepository.deleteRoom() }
        }
    }
}

#Preview {
    ListsView()
}
