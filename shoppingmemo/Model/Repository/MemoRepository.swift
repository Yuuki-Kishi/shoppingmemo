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
    static func updateIsChecked(memo: Memo) async {
        do {
            guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
            guard let listId = listDataStore.selectedList?.listId else { return }
            try await Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(listId).collection("Memos").document(memo.memoId).updateData(["isChecked": !memo.isChecked])
        } catch {
            print(error)
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
    
    static func updateNonCheckOrders(from: IndexSet, to: Int) async {
        var nonCheckMemoArray = memoDataStore.nonCheckMemoArray
        nonCheckMemoArray.move(fromOffsets: from, toOffset: to)
        for (index, memo) in nonCheckMemoArray.enumerated() {
            await updateNonCheckOrder(memoId: memo.memoId, newOrder: index)
        }
        sortNonCheckMemos(basedOn: .custom)
    }
    
    static func incrementNonCheckOrder() async {
        let memoIds = memoDataStore.nonCheckMemoArray.map { $0.memoId }
        for (index, memoId) in memoIds.enumerated() {
            await updateNonCheckOrder(memoId: memoId, newOrder: index + 1)
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
    
    static func updateCheckOrders(from: IndexSet, to: Int) async {
        var checkedMemoArray = memoDataStore.checkedMemoArray
        checkedMemoArray.move(fromOffsets: from, toOffset: to)
        for (index, memo) in checkedMemoArray.enumerated() {
            await updateCheckedOrder(memoId: memo.memoId, newOrder: index)
        }
        sortCheckedMemos(basedOn: .custom)
    }
    
    static func incrementCheckedOrder() async {
        let memoIds = memoDataStore.checkedMemoArray.map { $0.memoId }
        for (index, memoId) in memoIds.enumerated() {
            await updateCheckedOrder(memoId: memoId, newOrder: index + 1)
        }
    }

    
    static func sortNonCheckMemos(basedOn: MemoDataStore.SortModeEnum) {
        switch basedOn {
        case .ascending:
            memoDataStore.nonCheckMemoArray.sort { $0.memoName < $1.memoName }
        case .descending:
            memoDataStore.nonCheckMemoArray.sort { $0.memoName > $1.memoName }
        case .newest:
            memoDataStore.nonCheckMemoArray.sort { $0.creationTime > $1.creationTime }
        case .custom:
            memoDataStore.nonCheckMemoArray.sort { $0.nonCheckOrder < $1.nonCheckOrder }
        }
        memoDataStore.nonCheckSort = basedOn
        UserDefaultsRepository.save(data: basedOn.rawValue, key: "nonCheckSort")
    }
    
    static func sortCheckedMemos(basedOn: MemoDataStore.SortModeEnum) {
        switch basedOn {
        case .ascending:
            memoDataStore.checkedMemoArray.sort { $0.memoName < $1.memoName }
        case .descending:
            memoDataStore.checkedMemoArray.sort { $0.memoName > $1.memoName }
        case .newest:
            memoDataStore.checkedMemoArray.sort { $0.checkedTime > $1.checkedTime }
        case .custom:
            memoDataStore.checkedMemoArray.sort { $0.checkedOrder < $1.checkedOrder }
        }
        memoDataStore.checkedSort = basedOn
        UserDefaultsRepository.save(data: basedOn.rawValue, key: "checkedSort")
    }
    
    static func updateImageUrl(newImageUrl: String) async {
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        guard let listId = listDataStore.selectedList?.listId else { return }
        guard let memoId = memoDataStore.selectedMemo?.memoId else { return }
        do {
            try await Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(listId).collection("Memos").document(memoId).updateData(["imageUrl": newImageUrl])
        } catch {
            print(error)
        }
    }
    
    //delete
    static func clearMemos() {
        memoDataStore.selectedMemo = nil
        memoDataStore.nonCheckMemoArray.removeAll()
        memoDataStore.checkedMemoArray.removeAll()
    }
    
    //observe
    static func observeNonCheckMemos() {
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        guard let listId = listDataStore.selectedList?.listId else { return }
        Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(listId).collection("Memos").whereField("isChecked", isEqualTo: false).addSnapshotListener() { querySnapshot, error in
            do {
                guard let documentChanges = querySnapshot?.documentChanges else { return }
                for documentChange in documentChanges {
                    let document = documentChange.document
                    let memo = try document.data(as: Memo.self)
                    switch documentChange.type {
                    case .added:
                        memoDataStore.nonCheckMemoArray.append(noDupulicate: memo)
                    case .modified:
                        memoDataStore.nonCheckMemoArray.append(noDupulicate: memo)
                    case .removed:
                        memoDataStore.nonCheckMemoArray.remove(memo: memo)
                        if memoDataStore.selectedMemo?.memoId == memo.memoId {
                            memoDataStore.selectedMemo = nil
                            CustomImageRepository.clearImage()
                            MemoRepository.clearMemos()
                            NavigationRepository.removeViews(dest: .memos)
                        }
                    }
                }
                let nonCheckSortString = UserDefaultsRepository.get(String.self, key: "nonCheckSort") ?? "ascending"
                let nonCheckSort = MemoDataStore.SortModeEnum(rawValue: nonCheckSortString) ?? .ascending
                sortNonCheckMemos(basedOn: nonCheckSort)
                memoDataStore.nonCheckMemoIsLoading = false
            } catch {
                print(error)
            }
        }
    }
    
    static func observeCheckedMemos() {
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        guard let listId = listDataStore.selectedList?.listId else { return }
        Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(listId).collection("Memos").whereField("isChecked", isEqualTo: true).addSnapshotListener() { querySnapshot, error in
            do {
                guard let documentChanges = querySnapshot?.documentChanges else { return }
                for documentChange in documentChanges {
                    let document = documentChange.document
                    let memo = try document.data(as: Memo.self)
                    switch documentChange.type {
                    case .added:
                        memoDataStore.checkedMemoArray.append(noDupulicate: memo)
                    case .modified:
                        memoDataStore.checkedMemoArray.append(noDupulicate: memo)
                    case .removed:
                        memoDataStore.checkedMemoArray.remove(memo: memo)
                        if memoDataStore.selectedMemo?.memoId == memo.memoId {
                            memoDataStore.selectedMemo = nil
                            CustomImageRepository.clearImage()
                            MemoRepository.clearMemos()
                            NavigationRepository.removeViews(dest: .memos)
                        }
                    }
                }
                let checkedSortString = UserDefaultsRepository.get(String.self, key: "checkedSort") ?? "ascending"
                let checkedSort = MemoDataStore.SortModeEnum(rawValue: checkedSortString) ?? .ascending
                sortNonCheckMemos(basedOn: checkedSort)
                memoDataStore.checkedMemoIsLoading = false
            } catch {
                print(error)
            }
        }
    }
}
