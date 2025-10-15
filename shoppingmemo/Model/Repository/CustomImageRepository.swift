//
//  CutomImageRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/10.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import PhotosUI

@MainActor
class CustomImageRepository {
    static let userDataStore: UserDataStore = .shared
    static let roomDataStore: RoomDataStore = .shared
    static let listDataStore: ListDataStore = .shared
    static let memoDataStore: MemoDataStore = .shared
    static let imageDataStore: ImageDataStore = .shared
    static let storage = Storage.storage()
    
    //create
    static func createImage(selectedImage: PhotosPickerItem?) async {
        guard let data = try? await selectedImage?.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        guard let imageData = uiImage.jpegData(compressionQuality: 0.3) else { return }
        guard let userId = userDataStore.signInUser?.userId else { return }
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        guard let listId = listDataStore.selectedList?.listId else { return }
        guard let memoId = memoDataStore.selectedMemo?.memoId else { return }
        let imageRef = storage.reference().child(roomId).child(listId).child(memoId + ".jpg")
        let attachedMetadata = StorageMetadata()
        attachedMetadata.customMetadata = ["uploadUserId": userId]
        imageRef.putData(imageData, metadata: attachedMetadata) { putDataResult in
            switch putDataResult {
            case .success(_):
                imageRef.downloadURL { urlResult in
                    switch urlResult {
                    case .success(let imageUrl):
                        Task { await MemoRepository.updateImageUrl(newImageUrl: imageUrl.absoluteString) }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
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
        imageDataStore.userNameResult = nil
        imageDataStore.uploadUserName = nil
    }
    
    static func deleteImage(imageUrl: String) async {
        do {
            try await storage.reference(forURL: imageUrl).delete()
            await MemoRepository.updateImageUrl(newImageUrl: "default")
        } catch {
            print(error)
        }
    }
}
