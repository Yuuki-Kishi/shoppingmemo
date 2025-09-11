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
    @StateObject var pathDataStore = PathDataStore.shared
    
    var body: some View {
        NavigationStack(path: $pathDataStore.navigationPath) {
            ZStack {
                plusButton()
                if roomDataStore.roomArray.isEmpty {
                    Text("表示できるルームがありません")
                } else {
                    List(roomDataStore.roomArray) { room in
                        RoomsViewCell(roomDataStore: roomDataStore, pathDataStore: pathDataStore, room: room)
                    }
                }
            }
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
            .padding()
        }
    }
    @ViewBuilder
    func destination(path: PathDataStore.path) -> some View {
        switch path {
        case .lists:
            ListsView(userDataStore: userDataStore, roomDataStore: roomDataStore, pathDataStore: pathDataStore)
        case .memos:
            EmptyView()
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
                        .font(.system(size: 30))
                        .foregroundStyle(Color.primary)
                        .background(Circle().frame(width: 70, height: 70))
                        .frame(width: 70, height: 70)
                })
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
