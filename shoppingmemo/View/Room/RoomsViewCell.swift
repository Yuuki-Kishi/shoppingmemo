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
    
    var body: some View {
        VStack {
            Text(room.roomId)
                .font(.system(size: 25))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            HStack {
                Text(lastEditTime())
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Text(lastEditUserName())
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(1)
            }
        }
    }
    func lastEditTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.string(from: room.lastEditTime)
    }
    func lastEditUserName() -> String {
        //MARK: Need Update
        return room.lastEditUserId
    }
}

#Preview {
    RoomsViewCell(roomDataStore: RoomDataStore.shared, pathDataStore: PathDataStore.shared, room: Room())
}
