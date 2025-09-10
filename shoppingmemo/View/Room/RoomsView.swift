//
//  RoomView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/09.
//

import SwiftUI

struct RoomsView: View {
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
            .padding()
            .navigationDestination(for: PathDataStore.path.self) { path in
                destination(path: path)
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    @ViewBuilder
    func destination(path: PathDataStore.path) -> some View {
        switch path {
        case .lists:
            ListsView(roomDataStore: roomDataStore, pathDataStore: pathDataStore)
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
}

#Preview {
    RoomsView()
}
