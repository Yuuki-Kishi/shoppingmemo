//
//  RoomView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/09.
//

import SwiftUI

struct RoomsView: View {
    @ObservedObject var userDataStore: UserDataStore
    @StateObject var roomDataStore: RoomDataStore = .shared
    @StateObject var listDataStore: ListDataStore = .shared
    @StateObject var memoDataStore: MemoDataStore = .shared
    @StateObject var imageDataStore: ImageDataStore = .shared
    @StateObject var myInfoDataStore: MyInfoDataStore = .shared
    @StateObject var pathDataStore: PathDataStore = .shared
    
    @State private var newRoomNameText: String = ""
    @State private var newRoomCreateAlertIsPresented: Bool = false
    @State private var signOutAlertIsPresented: Bool = false
    
    var body: some View {
        NavigationStack(path: $pathDataStore.navigationPath) {
            ZStack {
                if roomDataStore.roomArray.isEmpty {
                    Text("表示できるルームがありません")
                } else {
                    List($roomDataStore.roomArray, id: \.roomId) { room in
                        RoomsViewCell(roomDataStore: roomDataStore, pathDataStore: pathDataStore, room: room)
                    }
                    .listRowSpacing(35)
                }
                plusButton()
                if roomDataStore.isLoading {
                    ProgressView()
                        .scaleEffect(2)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing, content: {
                    toolBarMenu()
                })
            }
            .alert("ルームを新規作成", isPresented: $newRoomCreateAlertIsPresented, actions: {
                newRoomCreateAlertActions()
            }, message: {
                Text("新規作成するルームの名前を入力してください。")
            })
            .alert("本当にサインアウトしますか？", isPresented: $signOutAlertIsPresented, actions: {
                signOutAlertActions()
            }, message: {
                Text("サインアウトすると、再度利用する際にサインインが必要になります。")
            })
            .navigationDestination(for: PathDataStore.path.self) { path in
                destination(path: path)
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
                roomDataStore.isLoading = true
                RoomRepository.observeRooms()
                CustomListRepository.clearLists()
            }
        }
    }
    @ViewBuilder
    func destination(path: PathDataStore.path) -> some View {
        switch path {
        case .lists:
            ListsView(roomDataStore: roomDataStore, listDataStore: listDataStore, pathDataStore: pathDataStore)
        case .memos:
            MemosView(listDataStore: listDataStore, memoDataStore: memoDataStore, pathDataStore: pathDataStore)
        case .image:
            ImageView(memoDataStore: memoDataStore, imageDataStore: imageDataStore, pathDataStore: pathDataStore)
        case .myInfo:
            MyInfoView(userDataStore: userDataStore, myInfoDataStore: myInfoDataStore)
        case .noticeList:
            EmptyView()
        case .notice:
            EmptyView()
        }
    }
    func plusButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    newRoomCreateAlertIsPresented = true
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
    func toolBarMenu() -> some View {
        Menu {
            Button(action: {
                pathDataStore.navigationPath.append(.myInfo)
            }, label: {
                Label("マイページ", systemImage: "info.circle")
            })
            Button(action: {
                
            }, label: {
                Label("設定", systemImage: "switch.2")
            })
            Button(action: {
                
            }, label: {
                Label("通知一覧", systemImage: "bell")
            })
            Button(action: {
                
            }, label: {
                Label("操作説明", systemImage: "questionmark.circle")
            })
            Divider()
            Button(role: .destructive, action: {
                signOutAlertIsPresented = true
            }, label: {
                Label("サインアウト", systemImage: "door.right.hand.open")
            })
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(Color.primary)
        }
    }
    @ViewBuilder
    func newRoomCreateAlertActions() -> some View {
        TextField("ルームの名前を入力", text: $newRoomNameText)
        Button(role: .cancel, action: {}, label: {
            Text("キャンセル")
        })
        Button(role: .confirm, action: {
            Task { await RoomRepository.createRoom(roomName: newRoomNameText) }
        }, label: {
            Text("作成")
        })
    }
    @ViewBuilder
    func signOutAlertActions() -> some View {
        Button(role: .cancel, action: {}, label: {
            Text("キャンセル")
        })
        Button(role: .destructive, action: {
            Task { await AuthRepository.signOut() }
        }, label: {
            Text("サインアウト")
        })
    }
}

#Preview {
    RoomsView(userDataStore: .shared)
}
