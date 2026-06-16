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
    @State private var enterRoomAlertIsPresented: Bool = false
    
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
        .alert("\(room.roomName)に加入しますか？", isPresented: $enterRoomAlertIsPresented) {
            Button(role: .cancel) {} label: {
                Text("保留")
            }
            Button(role: .confirm) {
                Task { await RoomRepository.updateMyAuthority(roomId: room.roomId) }
            } label: {
                Text("加入")
            }
            Button(role: .destructive) {
                Task { await RoomRepository.removeMyAuthority(roomId: room.roomId) }
            } label: {
                Text("拒否")
            }
        } message: {
            Text("後から自分で脱退することができます。")
        }
        .onTapGesture {
            if room.authorities.myAuthority == .guest {
                enterRoomAlertIsPresented = true
            } else {
                roomDataStore.selectedRoomId = room.roomId
                pathDataStore.navigationPath.append(.lists)
            }
        }
        .onAppear() {
            UserRepository.observeUserName(userId: room.lastUpdateUserId) { userName in
                lastUpdateUserName = userName ?? "----"
            }
        }
    }
    func roomName() -> String {
        if room.authorities.myAuthority == .guest {
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
        if room.authorities.myAuthority == .guest { return .orange }
        return nil
    }
}

#Preview {
    RoomsViewCell(room: Room())
}
