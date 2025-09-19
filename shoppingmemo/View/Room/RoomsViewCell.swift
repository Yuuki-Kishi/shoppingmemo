//
//  RoomsViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/10.
//

import SwiftUI

struct RoomsViewCell: View {
    @ObservedObject var roomDataStore: RoomDataStore
    @ObservedObject var pathDataStore: PathDataStore
    @State var room: Room
    @State var lastUpdateUserName: String = "取得中..."
    
    var body: some View {
        HStack {
            VStack {
                Text(roomName())
                    .font(.system(size: 25))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                HStack {
                    Text(lastUpdateTime())
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    Text(lastUpdateUserName)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                }
            }
            Image(systemName: "chevron.forward")
                .foregroundStyle(.gray)
        }
        .contentShape(Rectangle())
        .listRowBackground(cellColor())
        .onTapGesture {
            pathDataStore.navigationPath.append(.lists)
        }
        .task { lastUpdateUserName = await lastUpdateUserName() }
    }
    func roomName() -> String {
        if room.ownAuthority == .guest {
            return room.roomName + " (招待されています)"
        } else {
            return room.roomName
        }
    }
    func lastUpdateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.string(from: room.lastUpdateTime)
    }
    func lastUpdateUserName() async -> String {
        if let user = await UserRepository.getUserData(userId: room.lastUpdateUserId) {
            return user.userName
        } else {
            return "エラー"
        }
    }
    func cellColor() -> Color? {
        if room.ownAuthority == .guest { return .orange }
        return nil
    }
}

#Preview {
    RoomsViewCell(roomDataStore: RoomDataStore.shared, pathDataStore: PathDataStore.shared, room: Room())
}
