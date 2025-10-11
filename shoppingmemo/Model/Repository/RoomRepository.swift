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
    static func createRoom(roomName: String) async {
        do {
            guard let userId = userDataStore.signInUser?.userId else { return }
            let room = Room(roomName: roomName, userId: userId)
            let encoded = try JSONEncoder().encode(room)
            guard let jsonObject = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any] else { return }
            try await Firestore.firestore().collection("Rooms").document(room.roomId).setData(jsonObject)
        } catch {
            print(error)
        }
    }
    
    //check
    
    //get
    
    //update
    static func updateRoomName(newName: String) async {
        do {
            guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
            try await Firestore.firestore().collection("Rooms").document(roomId).updateData(["roomName": newName])
        } catch {
            print(error)
        }
    }
    
    //delete
    
    //observe
    static func observeRooms() {
        guard let userId = userDataStore.signInUser?.userId else { return }
        Firestore.firestore().collection("Rooms").whereField("memberIds", arrayContains: userId).addSnapshotListener() { querySnapshot, error in
            do {
                guard let documentChanges = querySnapshot?.documentChanges else { return }
                for documentChange in documentChanges {
                    let document = documentChange.document
                    let room = try document.data(as: Room.self)
                    switch documentChange.type {
                    case .added:
                        roomDataStore.roomArray.append(noDupulicate: room)
                    case .modified:
                        roomDataStore.roomArray.append(noDupulicate: room)
                        if room.roomId == roomDataStore.selectedRoom?.roomId {
                            roomDataStore.selectedRoom = room
                        }
                    case .removed:
                        roomDataStore.roomArray.remove(room: room)
                        if room.roomId == roomDataStore.selectedRoom?.roomId {
                            roomDataStore.selectedRoom = nil
                            NavigationRepository.removeViews(numberOfLeave: 0)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}
