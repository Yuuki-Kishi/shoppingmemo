//
//  RoomView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/09.
//

import SwiftUI

struct RoomsView: View {
    @ObservedObject var userDataStore: UserDataStore
    @StateObject var roomDataStore = RoomDataStore.shared
    @StateObject var listDataStore = ListDataStore.shared
    @StateObject var memoDataStore = MemoDataStore.shared
    @StateObject var pathDataStore = PathDataStore.shared
    
    var body: some View {
        NavigationStack(path: $pathDataStore.navigationPath) {
            ZStack {
                if roomDataStore.roomArray.isEmpty {
                    VStack {
                        Text("表示できるルームがありません")
                            .padding()
                    }
                } else {
                    List(roomDataStore.roomArray, id: \.roomId) { room in
                        Section {
                            RoomsViewCell(roomDataStore: roomDataStore, pathDataStore: pathDataStore, room: room)
                        }
                    }
                }
                plusButton()
            }
            .background(Color(UIColor.systemGray6))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing, content: {
                    toolBarMenu()
                })
            }
            .navigationDestination(for: PathDataStore.path.self) { path in
                destination(path: path)
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
                UserRepository.observeBelongRooms()
            }
        }
    }
    @ViewBuilder
    func destination(path: PathDataStore.path) -> some View {
        switch path {
        case .lists:
            ListsView(userDataStore: userDataStore, roomDataStore: roomDataStore, listDataStore: listDataStore, pathDataStore: pathDataStore)
        case .memos:
            MemosView(userDataStore: userDataStore, roomDataStore: roomDataStore, listDataStore: listDataStore, memoDataStore: memoDataStore)
        case .image:
            EmptyView()
        case .myInfo:
            EmptyView()
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
                
            }, label: {
                Label("サインアウト", systemImage: "door.right.hand.open")
            })
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(Color.primary)
        }
    }
}

#Preview {
    RoomsView(userDataStore: UserDataStore.shared)
}
