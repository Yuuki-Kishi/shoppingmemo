//
//  ListsView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/11.
//

import SwiftUI

struct ListsView: View {
    @ObservedObject var userDataStore: UserDataStore
    @ObservedObject var roomDataStore: RoomDataStore
    @ObservedObject var listDataStore: ListDataStore
    @ObservedObject var pathDataStore: PathDataStore
    
    var body: some View {
        ZStack {
            if listDataStore.listArray.isEmpty {
                Text("表示できるリストがありません")
                    .padding()
            } else {
                List(listDataStore.listArray) { list in
                    Section {
                        ListViewCell(listDataStore: listDataStore, pathDataStore: pathDataStore, list: list)
                    }
                }
            }
            plusButton()
        }
        .background(Color(UIColor.systemGray6))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                HStack {
                    
                    toolBarMenu()
                }
            })
        }
        .navigationTitle(roomDataStore.selectedRoom?.roomName ?? "不明なルーム")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            listDataStore.listArray.append(CustomList())
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
                Label("ルーム名を変更", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            })
            Button(action: {
                
            }, label: {
                Label("メンバーリスト", systemImage: "person.2")
            })
            Button(action: {
                
            }, label: {
                Label("並び替え", systemImage: "arrow.up.arrow.down")
            })
            Divider()
            Button(role: .destructive, action: {
                
            }, label: {
                Label("管理者権限を譲渡", systemImage: "person.line.dotted.person")
            })
            Button(role: .destructive, action: {
                
            }, label: {
                Label("ルーム削除", systemImage: "trash")
            })
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

#Preview {
    ListsView(userDataStore: UserDataStore.shared, roomDataStore: RoomDataStore.shared, listDataStore: ListDataStore.shared, pathDataStore: PathDataStore.shared)
}
