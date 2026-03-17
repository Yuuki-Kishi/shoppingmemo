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
    static func updateListName(newName: String) async {
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        guard let listId = listDataStore.selectedList?.listId else { return }
        do {
            try await Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(listId).updateData(["listName": newName])
        } catch {
            print(error)
        }
    }
    
    static func updateListOrders(from: IndexSet, to: Int) async {
        do {
            guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
            var listArray = listDataStore.listArray
            listArray.move(fromOffsets: from, toOffset: to)
            for (index, list) in listArray.enumerated() {
                try await Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(list.listId).updateData(["listOrder": index])
            }
            sortLists(basedOn: .custom)
        } catch {
            print(error)
        }
    }
    
    static func sortLists(basedOn: ListDataStore.SortModeEnum) {
        switch basedOn {
        case .ascending:
            listDataStore.listArray.sort { $0.listName < $1.listName }
        case .descending:
            listDataStore.listArray.sort { $0.listName > $1.listName }
        case .newest:
            listDataStore.listArray.sort { $0.lastUpdateTime > $1.lastUpdateTime }
        case .custom:
            listDataStore.listArray.sort { $0.listOrder < $1.listOrder }
        }
        listDataStore.listSort = basedOn
        UserDefaultsRepository.save(data: basedOn.rawValue, key: "listSort")
    }
    
    //delete
    static func clearLists() {
        listDataStore.selectedList = nil
        listDataStore.listArray.removeAll()
    }
    
    //observe
    static func observeLists() {
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").addSnapshotListener() { querySnapshot, error in
            do {
                guard let documentChanges = querySnapshot?.documentChanges else { return }
                for documentChange in documentChanges {
                    let document = documentChange.document
                    let list = try document.data(as: CustomList.self)
                    switch documentChange.type {
                    case .added:
                        listDataStore.listArray.append(noDupulicate: list)
                    case .modified:
                        listDataStore.listArray.append(noDupulicate: list)
                        if list.listId == listDataStore.selectedList?.listId {
                            listDataStore.selectedList = list
                        }
                    case .removed:
                        listDataStore.listArray.remove(list: list)
                        if list.listId == listDataStore.selectedList?.listId {
                            listDataStore.selectedList = nil
                            NavigationRepository.removeViews(numberOfLeave: 1)
                        }
                    }
                }
                let listSortString = UserDefaultsRepository.get(String.self, key: "listSort") ?? "ascending"
                let listSort = ListDataStore.SortModeEnum(rawValue: listSortString) ?? .ascending
                sortLists(basedOn: listSort)
                listDataStore.isLoading = false
            } catch {
                print(error)
            }
        }
    }
}
