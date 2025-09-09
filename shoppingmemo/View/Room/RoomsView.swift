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
            List(roomDataStore.roomArray) { room in
                RoomsViewCell(roomDataStore: roomDataStore, pathDataStore: pathDataStore, room: room)
            }
            .navigationDestination(for: PathDataStore.path.self) { path in
                destination(path: path)
            }
        }
    }
    func destination(path: PathDataStore.path) -> some View {
        switch path {
        case .lists:
            EmptyView()
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
}

#Preview {
    RoomsView()
}
