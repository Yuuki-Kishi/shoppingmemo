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
        guard let memoId = memoDataStore.selectedMemo?.memoId else { return }
        storage.reference(forURL: imageUrl).getData(maxSize: 1 * 1024 * 1024) { dataResult in
            switch dataResult {
            case .success(let imageData):
                storage.reference(forURL: imageUrl).getMetadata() { metadataResult in
                    switch metadataResult {
                    case .success(let metadata):
                        guard let uploadTime = metadata.updated else { return }
                        let uploadUserId = metadata.customMetadata?["uploadUserId"] ?? "unknownUserId"
                        imageDataStore.selectedMemoImage = CustomImage(memoId: memoId, imageData: imageData, uploadTime: uploadTime, uploadUserId: uploadUserId)
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //delete
    static func clearImage() {
        imageDataStore.selectedMemoImage = nil
    }
}
