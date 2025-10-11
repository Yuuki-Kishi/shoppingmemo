//
//  MemoRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/29.
//

import Foundation
import FirebaseFirestore

@MainActor
class MemoRepository {
    static let userDataStore: UserDataStore = .shared
    static let roomDataStore: RoomDataStore = .shared
    static let listDataStore: ListDataStore = .shared
    static let memoDataStore: MemoDataStore = .shared
    static let imageDataStore: ImageDataStore = .shared
    
    //create
    static func createMemo(memoName: String) async {
        do {
            guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
            guard let listId = listDataStore.selectedList?.listId else { return }
            let memo = Memo(memoName: memoName)
            let encoded = try JSONEncoder().encode(memo)
            guard let jsonObject = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any] else { return }
            await incrementNonCheckOrder()
            await incrementCheckedOrder()
            try await Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(listId).collection("Memos").document(memo.memoId).setData(jsonObject)
        } catch {
            print(error)
        }
    }
    
    //check
    
    //get
    
    //update
    static func incrementNonCheckOrder() async {
        let memoIds = memoDataStore.nonCheckMemoArray.map { $0.memoId }
        for (index, memoId) in memoIds.enumerated() {
            await updateNonCheckOrder(memoId: memoId, newOrder: index + 1)
        }
    }
    
    static func updateNonCheckOrder(memoId: String, newOrder: Int) async {
        do {
            guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
            guard let listId = listDataStore.selectedList?.listId else { return }
            try await Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(listId).collection("Memos").document(memoId).updateData(["nonCheckOrder": newOrder])
        } catch {
            print(error)
        }
    }
    
    static func incrementCheckedOrder() async {
        let memoIds = memoDataStore.checkedMemoArray.map { $0.memoId }
        for (index, memoId) in memoIds.enumerated() {
            await updateCheckedOrder(memoId: memoId, newOrder: index + 1)
        }
    }
    
    static func updateCheckedOrder(memoId: String, newOrder: Int) async {
        do {
            guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
            guard let listId = listDataStore.selectedList?.listId else { return }
            try await Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(listId).collection("Memos").document(memoId).updateData(["checkedOrder": newOrder])
        } catch {
            print(error)
        }
    }
    
    static func sortNonCheckMemoArray(sortMode: MemoDataStore.SortModeEnum) {
        switch sortMode {
        case .ascending:
            memoDataStore.nonCheckMemoArray.sort { $0.memoName < $1.memoName }
        case .descending:
            memoDataStore.nonCheckMemoArray.sort { $0.memoName > $1.memoName }
        case .newest:
            memoDataStore.nonCheckMemoArray.sort { $0.creationTime > $1.creationTime }
        case .custom:
            memoDataStore.nonCheckMemoArray.sort { $0.nonCheckOrder < $1.nonCheckOrder }
        }
        memoDataStore.nonCheckSort = sortMode
    }
    
    static func sortCheckedMemoArray(sortMode: MemoDataStore.SortModeEnum) {
        switch sortMode {
        case .ascending:
            memoDataStore.checkedMemoArray.sort { $0.memoName < $1.memoName }
        case .descending:
            memoDataStore.checkedMemoArray.sort { $0.memoName > $1.memoName }
        case .newest:
            memoDataStore.checkedMemoArray.sort { $0.checkedTime > $1.checkedTime }
        case .custom:
            memoDataStore.checkedMemoArray.sort { $0.checkedOrder < $1.checkedOrder }
        }
        memoDataStore.checkedSort = sortMode
    }
    
    //delete
    static func clearMemos() {
        memoDataStore.selectedMemo = nil
        memoDataStore.nonCheckMemoArray.removeAll()
        memoDataStore.checkedMemoArray.removeAll()
    }
    
    //observe
    static func obserbeMemos() {
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        guard let listId = listDataStore.selectedList?.listId else { return }
        Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(listId).collection("Memos").addSnapshotListener() { querySnapshot, error in
            guard let documentChanges = querySnapshot?.documentChanges else { return }
            for documentChange in documentChanges {
                do {
                    let document = documentChange.document
                    let memo = try document.data(as: Memo.self)
                    switch documentChange.type {
                    case .added:
                        if memo.isChecked {
                            memoDataStore.checkedMemoArray.append(noDupulicate: memo)
                        } else {
                            memoDataStore.nonCheckMemoArray.append(noDupulicate: memo)
                        }
                    case .modified:
                        if memo.isChecked {
                            memoDataStore.checkedMemoArray.append(noDupulicate: memo)
                        } else {
                            memoDataStore.nonCheckMemoArray.append(noDupulicate: memo)
                        }
                    case .removed:
                        if memo.isChecked {
                            memoDataStore.checkedMemoArray.remove(memo: memo)
                        } else {
                            memoDataStore.nonCheckMemoArray.remove(memo: memo)
                        }
                        if memo.memoId == memoDataStore.selectedMemo?.memoId {
                            memoDataStore.selectedMemo = nil
                            NavigationRepository.removeViews(numberOfLeave: 2)
                        }
                    }
                } catch {
                    print(error)
                }
            }
            sortNonCheckMemoArray(sortMode: memoDataStore.nonCheckSort)
            sortNonCheckMemoArray(sortMode: memoDataStore.checkedSort)
        }
    }
}
