//
//  CustomListRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class CustomListRepository {
    static let userDataStore: UserDataStore = .shared
    static let roomDataStore: RoomDataStore = .shared
    static let listDataStore: ListDataStore = .shared
    
    //create
    static func createList(listName: String) async {
        do {
            guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
            guard let userId = userDataStore.signInUser?.userId else { return }
            let list = CustomList(listName: listName, lastUpdateUserId: userId)
            let encoded = try JSONEncoder().encode(list)
            guard let jsonObject = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any] else { return }
            try await Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(list.listId).setData(jsonObject)
        } catch {
            print(error)
        }
    }
    
    //check
    
    
    //get
    
    
    //update
    
    
    //delete
    
    
    //observe
    static func observeLists() {
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").addSnapshotListener() { querySnapshot, error in
            guard let documentChanges = querySnapshot?.documentChanges else { return }
            for documentChange in documentChanges {
                do {
                    let document = documentChange.document
                    let list = try document.data(as: CustomList.self)
                    switch documentChange.type {
                    case .added:
                        listDataStore.listArray.append(noDupulicate: list)
                    case .modified:
                        listDataStore.listArray.append(noDupulicate: list)
                    case .removed:
                        listDataStore.listArray.remove(list: list)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}
