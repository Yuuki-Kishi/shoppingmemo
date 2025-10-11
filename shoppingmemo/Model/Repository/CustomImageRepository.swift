//
//  CutomImageRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/10.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

@MainActor
class CustomImageRepository {
    static let userDataStore: UserDataStore = .shared
    static let roomDataStore: RoomDataStore = .shared
    static let listDataStore: ListDataStore = .shared
    static let memoDataStore: MemoDataStore = .shared
    static let imageDataStore: ImageDataStore = .shared
    static let storage = Storage.storage()
    
    
    //get
    static func getImage(imageUrl: String) {
        if imageUrl == "default" { return }
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        guard let listId = listDataStore.selectedList?.listId else { return }
        guard let memoId = memoDataStore.selectedMemo?.memoId else { return }
        storage.reference(forURL: imageUrl).getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
                return
            }
            guard let imageData = data else { return }
            storage.reference(forURL: imageUrl).getMetadata { metadata, error in
                guard let lastUpdateTime = metadata?.updated else { return }
                imageDataStore.selectedMemoImage = CustomImage(roomId: roomId, listId: listId, memoId: memoId, imageData: imageData, lastUpdateTime: lastUpdateTime)
            }
        }
    }
    
    //delete
    static func clearImage() {
        imageDataStore.selectedMemoImage = nil
    }
}
