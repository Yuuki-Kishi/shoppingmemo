//
//  RoomsViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/10.
//

import SwiftUI

struct RoomsViewCell: View {
    @EnvironmentObject private var roomDataStore: RoomDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    private let room: Room
    @State private var lastUpdateUserName: String = "----"
    
    init(room: Room) {
        self.room = room
    }
    
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
            roomDataStore.selectedRoomId = room.roomId
            pathDataStore.navigationPath.append(.lists)
        }
        .onAppear() {
            UserRepository.observeUserName(userId: room.lastUpdateUserId) { userName in
                lastUpdateUserName = userName ?? "----"
            }
        }
    }
    func roomName() -> String {
        if room.authorities.mine == .guest {
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
    func cellColor() -> Color? {
        if room.authorities.mine == .guest { return .orange }
        return nil
    }
}

#Preview {
    RoomsViewCell(room: Room())
}
