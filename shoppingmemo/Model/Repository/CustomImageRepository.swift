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
        guard let imageData = uiImage.jpegData(compressionQuality: 0.2) else { return }
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
    static func getImage(imageUrl: String) async {
        if imageUrl == "default" {
            imageDataStore.attachedImage = nil
            imageDataStore.isLoading = false
            return
        }
        do {
            let imageData = try await storage.reference(forURL: imageUrl).data(maxSize: 1 * 1024 * 1024)
            let metadata = try await storage.reference(forURL: imageUrl).getMetadata()
            guard let uploadTime = metadata.updated else { return }
            let uploadUserId = metadata.customMetadata?["uploadUserId"] ?? "unknownUserId"
            imageDataStore.attachedImage = CustomImage(imageUrl: imageUrl, imageData: imageData, uploadTime: uploadTime, uploadUserId: uploadUserId)
            imageDataStore.isLoading = false
        } catch {
            print(error)
        }
    }
    
    //delete
    static func clearImage() {
        imageDataStore.attachedImage = nil
    }
    
    static func deleteImage() async {
        do {
            guard let imageUrl = imageDataStore.attachedImage?.imageUrl else { return }
            try await storage.reference(forURL: imageUrl).delete()
            await MemoRepository.updateImageUrl(newImageUrl: "default")
        } catch {
            print(error)
        }
    }
    
    //observe
    static func observeImageUrl() {
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        guard let listId = listDataStore.selectedList?.listId else { return }
        guard let memoId = memoDataStore.selectedMemo?.memoId else { return }
        Firestore.firestore().collection("Rooms").document(roomId).collection("Lists").document(listId).collection("Memos").document(memoId).addSnapshotListener() { DataSnapshot, error in
            do {
                guard let newMemo = try DataSnapshot?.data(as: Memo.self) else { return }
                if let previousImage = imageDataStore.attachedImage {
                    if previousImage.imageUrl != newMemo.imageUrl {
                        imageDataStore.isLoading = true
                        Task { await getImage(imageUrl: newMemo.imageUrl) }
                    }
                } else {
                    if newMemo.imageUrl == "default" {
                        imageDataStore.isLoading = false
                    } else {
                        imageDataStore.isLoading = true
                        Task { await getImage(imageUrl: newMemo.imageUrl) }
                    }
                }
                
            } catch {
                print(error)
            }
        }
    }
}
