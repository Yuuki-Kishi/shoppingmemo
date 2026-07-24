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
                Text(room.roomName)
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
        .alert("\(room.roomName)RoomsViewCell.Alert.title", isPresented: $enterRoomAlertIsPresented) {
            Button(role: .cancel) {} label: {
                Text("RoomsViewCell.Alert.holdButton.Text")
            }
            Button(role: .confirm) {
                Task { await RoomRepository.updateMyAuthority(roomId: room.roomId) }
            } label: {
                Text("RoomsViewCell.Alert.joinButton.Text")
            }
            Button(role: .destructive) {
                Task { await RoomRepository.removeMyAuthority(roomId: room.roomId) }
            } label: {
                Text("RoomsViewCell.Alert.rejectButton.Text")
            }
        } message: {
            Text("RoomsViewCell.Alert.message")
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
