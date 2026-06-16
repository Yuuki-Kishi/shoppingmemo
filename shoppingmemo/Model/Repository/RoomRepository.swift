//
//  RoomRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/16.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

@MainActor
class RoomRepository {
    static let userDataStore: UserDataStore = .shared
    static let roomDataStore: RoomDataStore = .shared
    static let functions: Functions = .functions(region: "asia-northeast1")
    
    //create
    static func createRoom(roomName: String) async {
        guard !roomName.isEmpty else { return }
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
            guard let roomId = roomDataStore.roomArray.selected?.roomId else { return }
            try await Firestore.firestore().collection("Rooms").document(roomId).updateData(["roomName": newName])
        } catch {
            print(error)
        }
    }
    
    static func addAuthority(userId: String) async {
        do {
            guard let roomId = roomDataStore.roomArray.selected?.roomId else { return }
            let authority = Authority(userId: userId, authority: .guest)
            let encoded = try JSONEncoder().encode(authority)
            guard let jsonObject = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any] else { return }
            try await Firestore.firestore().collection("Rooms").document(roomId).updateData(["authorities": FieldValue.arrayUnion([jsonObject])])
            try await Firestore.firestore().collection("Rooms").document(roomId).updateData(["memberIds": FieldValue.arrayUnion([userId])])
        } catch {
            print(error)
        }
    }
    
    static func removeAuthority(authority: Authority) async {
        do {
            guard let roomId = roomDataStore.roomArray.selected?.roomId else { return }
            let encoded = try JSONEncoder().encode(authority)
            guard let jsonObject = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any] else { return }
            try await Firestore.firestore().collection("Rooms").document(roomId).updateData(["authorities": FieldValue.arrayRemove([jsonObject])])
            try await Firestore.firestore().collection("Rooms").document(roomId).updateData(["memberIds": FieldValue.arrayRemove([authority.userId])])
        } catch {
            print(error)
        }
    }
    
    static func updateMyAuthority(roomId: String, authority: Authority) async {
        do {
            guard let userId = userDataStore.signInUser?.userId else { return }
            let encoded = try JSONEncoder().encode(authority)
            guard let jsonObject = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any] else { return }
            try await Firestore.firestore().collection("Rooms").document(roomId).updateData(["authorities": FieldValue.arrayRemove([jsonObject])])
            let newAuthority = Authority(userId: userId, authority: .member)
            let newEncoded = try JSONEncoder().encode(newAuthority)
            guard let newJsonObject = try JSONSerialization.jsonObject(with: newEncoded, options: []) as? [String: Any] else { return }
            try await Firestore.firestore().collection("Rooms").document(roomId).updateData(["authorities": FieldValue.arrayUnion([newJsonObject])])
        } catch {
            print(error)
        }
    }
    
    //delete
    static func deleteRoom() async {
        do {
            guard let roomId = roomDataStore.roomArray.selected?.roomId else { return }
            let path = "Rooms/\(roomId)"
            let _ = try await functions.httpsCallable("recursiveDelete").call(["path": path])
        } catch {
            print(error)
        }
    }
    
    //observe
    static func observeRooms(completion: @escaping () -> Void) {
        guard let userId = userDataStore.signInUser?.userId else { completion(); return }
        Firestore.firestore().collection("Rooms").whereField("memberIds", arrayContains: userId).addSnapshotListener() { querySnapshot, error in
            do {
                guard let documentChanges = querySnapshot?.documentChanges else {
                    print("Failed to get documentChanges")
                    completion()
                    return
                }
                for documentChange in documentChanges {
                    let document = documentChange.document
                    let room = try document.data(as: Room.self)
                    switch documentChange.type {
                    case .added:
                        roomDataStore.roomArray.append(noDuplicate: room)
                    case .modified:
                        roomDataStore.roomArray.append(noDuplicate: room)
                    case .removed:
                        roomDataStore.roomArray.remove(room: room)
                        if room.roomId == roomDataStore.roomArray.selected?.roomId {
                            roomDataStore.selectedRoomId = nil
                            NavigationRepository.removeAllViews()
                        }
                    }
                }
                roomDataStore.roomArray.sort { $0.lastUpdateTime > $1.lastUpdateTime }
                completion()
            } catch {
                print(error)
                completion()
            }
        }
    }
    
    
}
