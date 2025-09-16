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
        guard let authorities = userDataStore.signInUser?.authority else { return [] }
        for authority in authorities {
            let roomId = authority.roomId
            guard let room = await getRoom(roomId: roomId) else { continue }
            rooms.append(noDupulicate: room)
        }
        return rooms
    }
    
    //update
    
    //delete
    
    //observe
}
