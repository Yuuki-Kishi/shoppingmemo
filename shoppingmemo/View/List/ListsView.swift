//
//  ListsView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/11.
//

import SwiftUI

struct ListsView: View {
    @ObservedObject var roomDataStore: RoomDataStore
    @ObservedObject var listDataStore: ListDataStore
    @ObservedObject var pathDataStore: PathDataStore
    
    @State private var newListNameText: String = ""
    @State private var newRoomNameText: String = ""
    @State private var createNewListAlertIsPresent: Bool = false
    @State private var updateRoomNameAlertIsPresent: Bool = false
    @State private var deleteRoomAlertIsPresent: Bool = false
    
    var body: some View {
        ZStack {
            if listDataStore.isLoading {
                Text("データ取得中...")
            } else {
                if listDataStore.listArray.isEmpty {
                    Text("表示できるリストがありません")
                } else {
                    List {
                        ForEach($listDataStore.listArray, id: \.listId) { list in
                            ListsViewCell(listDataStore: listDataStore, pathDataStore: pathDataStore, list: list)
                        }
                        .onMove(perform: move)
                        .onDelete(perform: delete)
                    }
                    .listRowSpacing(35)
                }
                plusButton()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                HStack {
                    
                    toolBarMenu()
                }
            })
        }
        .alert("リストを追加", isPresented: $createNewListAlertIsPresent, actions: {
            TextField("リストの名前を入力", text: $newListNameText)
            Button(role: .cancel, action: {
                newListNameText = ""
            }, label: {
                Text("キャンセル")
            })
            Button(action: {
                Task { await CustomListRepository.createList(listName: newListNameText) }
            }, label: {
                Text("追加")
            })
        }, message: {
            Text("追加するリストの名前を入力してください。")
        })
        .alert("ルーム名を変更", isPresented: $updateRoomNameAlertIsPresent, actions: {
            TextField("新しいルーム名を入力", text: $newRoomNameText)
            Button(role: .cancel, action: {
                newRoomNameText = roomDataStore.selectedRoom?.roomName ?? ""
            }, label: {
                Text("キャンセル")
            })
            Button(role: .confirm, action: {
                Task { await RoomRepository.updateRoomName(newName: newRoomNameText) }
            }, label: {
                Text("変更")
            })
        }, message: {
            Text("新しく設定するルーム名を入力してください。")
        })
        .alert("本当にルームを削除しますか？", isPresented: $deleteRoomAlertIsPresent, actions: {
            Button(role: .cancel, action: {}, label: {
                Text("キャンセル")
            })
            Button(role: .destructive, action: {
                Task { await RoomRepository.deleteRoom() }
            }, label: {
                Text("削除")
            })
        }, message: {
            Text("中に含まれる全てのリスト、メモも削除されます。\nこの操作は取り消すことができません。")
        })
        .navigationTitle(roomDataStore.selectedRoom?.roomName ?? "不明なルーム")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            listDataStore.isLoading = true
            CustomListRepository.observeLists()
            MemoRepository.clearMemos()
        }
    }
    func move(fromSources: IndexSet, toDestination: Int) {
        Task { await CustomListRepository.updateListOrders(from: fromSources, to: toDestination) }
    }
    func delete(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let listId = listDataStore.listArray[index].listId
        Task { await CustomListRepository.deleteList(listId: listId) }
    }
    func plusButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    newListNameText = ""
                    createNewListAlertIsPresent = true
                }, label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.primary)
                        .font(.system(size: 30))
                })
                .frame(width: 70, height: 70)
                .glassEffect(.regular.tint(.accentColor))
                .padding(.trailing, 34)
            }
        }
    }
    func toolBarMenu() -> some View {
        Menu {
            Button(action: {
                newRoomNameText = roomDataStore.selectedRoom?.roomName ?? ""
                updateRoomNameAlertIsPresent = true
            }, label: {
                Label("ルーム名を変更", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            })
            Button(action: {
                
            }, label: {
                Label("メンバーリスト", systemImage: "person.2")
            })
            Menu {
                Button(action: {
                    CustomListRepository.sortLists(basedOn: .ascending)
                }, label: {
                    Label("名前昇順", systemImage: "a.circle")
                })
                Button(action: {
                    CustomListRepository.sortLists(basedOn: .descending)
                }, label: {
                    Label("名前降順", systemImage: "z.circle")
                })
                Button(action: {
                    CustomListRepository.sortLists(basedOn: .newest)
                }, label: {
                    Label("更新日時", systemImage: "clock")
                })
                Button(action: {
                    CustomListRepository.sortLists(basedOn: .custom)
                }, label: {
                    Label("カスタム", systemImage: "hand.point.up")
                })
            } label: {
                Label("並び替え", systemImage: "arrow.up.arrow.down")
            }
            Divider()
            Button(role: .destructive, action: {
                
            }, label: {
                Label("管理者権限を譲渡", systemImage: "person.line.dotted.person")
            })
            Button(role: .destructive, action: {
                deleteRoomAlertIsPresent = true
            }, label: {
                Label("ルーム削除", systemImage: "trash")
            })
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

#Preview {
    ListsView(roomDataStore: .shared, listDataStore: .shared, pathDataStore: .shared)
}
