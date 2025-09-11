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
    @StateObject var listDataStore = ListDataStore.shared
    @ObservedObject var pathDataStore: PathDataStore
    
    var body: some View {
        List(listDataStore.listArray) { list in
            ListViewCell(listDataStore: listDataStore, pathDataStore: pathDataStore, list: list)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                toolBarMenu()
            })
        }
        .navigationTitle(roomDataStore.selectedRoom?.roomName ?? "不明なルーム")
        .navigationBarTitleDisplayMode(.inline)
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
    ListsView(userDataStore: UserDataStore.shared, roomDataStore: RoomDataStore.shared, pathDataStore: PathDataStore.shared)
}
