//
//  RoomRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/16.
//

import Foundation
import FirebaseFirestore

@MainActor
class RoomRepository {
    static let userDataStore = UserDataStore.shared
    static let roomDataStore = RoomDataStore.shared
    
    //create
    
    //check
    
    //get
    static func getRoom(roomId: String) async -> Room? {
        do {
            let document = try await Firestore.firestore().collection("rooms").document(roomId).getDocument()
            let room = try document.data(as: Room.self)
            return room
        } catch {
            print(error)
            return nil
        }
    }
    
    static func getBelongRooms() async -> [Room] {
        var rooms: [Room] = []
        guard let authorities = userDataStore.signInUser?.authorities else { return [] }
        for authority in authorities {
            let roomId = authority.roomId
            guard let room = await getRoom(roomId: roomId) else { continue }
            rooms.append(noDupulicate: room)
        }
        return rooms
    }
    
    //update
    static func updateRooms(authorities: [Authority]) async {
        if authorities.count < roomDataStore.roomArray.count {
            for currentRoom in roomDataStore.roomArray {
                let isContain = authorities.contains(where: { $0.roomId == currentRoom.roomId })
                if !isContain {
                    roomDataStore.roomArray.append(noDupulicate: currentRoom)
                }
            }
        }
        for authority in authorities {
            let roomId = authority.roomId
            let ownAuthority = authority.authority
            guard var room = await RoomRepository.getRoom(roomId: roomId) else { continue }
            room.ownAuthority = ownAuthority
            roomDataStore.roomArray.append(noDupulicate: room)
        }
        roomDataStore.roomArray.sort { $0.lastUpdateTime > $1.lastUpdateTime }
        let guests = roomDataStore.roomArray.filter { $0.ownAuthority == .guest }
        let others = roomDataStore.roomArray.filter { $0.ownAuthority != .guest }
        roomDataStore.roomArray = guests + others
    }
    
    //delete
    
    //observe
}
