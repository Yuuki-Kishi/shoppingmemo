//
//  ImageView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/10.
//

import SwiftUI
import PhotosUI

struct ImageView: View {
    @ObservedObject var userDataStore: UserDataStore
    @ObservedObject var roomDataStore: RoomDataStore
    @ObservedObject var listDataStore: ListDataStore
    @ObservedObject var memoDataStore: MemoDataStore
    @ObservedObject var imageDataStore: ImageDataStore
    @ObservedObject var pathDataStore: PathDataStore
    
    @State private var selectedImage: PhotosPickerItem?
    
    @State private var photosPickerIsPresented: Bool = false
    
    var body: some View {
        VStack {
            if let uiImage = getUIImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Spacer()
                Image(systemName: "photo")
                    .font(.system(size: 100))
                Text("No Image")
                    .font(.system(size: 40))
                Spacer()
            }
        }
        .photosPicker(isPresented: $photosPickerIsPresented, selection: $selectedImage)
        .onChange(of: selectedImage) {
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                toolBarMenu()
            })
        }
        .navigationTitle(memoDataStore.selectedMemo?.memoName ?? "不明なメモ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            CustomImageRepository.getImage(imageUrl: memoDataStore.selectedMemo?.imageUrl ?? "default")
        }
    }
    func getUIImage() -> UIImage? {
        if let imageData = imageDataStore.selectedMemoImage?.imageData {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    }
    func toolBarMenu() -> some View {
        ZStack {
            if imageDataStore.selectedMemoImage == nil {
                Menu {
                    Button(action: {
                        photosPickerIsPresented = true
                    }, label: {
                        Label("アルバムから追加", systemImage: "photo.stack")
                    })
                    Button(action: {
                        
                    }, label: {
                        Label("撮影して追加", systemImage: "camera")
                    })
                } label: {
                    Image(systemName: "plus")
                }
            } else {
                Menu {
                    Button(action: {
                        
                    }, label: {
                        Label("情報", systemImage: "info.circle")
                    })
                    Divider()
                    Button(role: .destructive, action: {
                        
                    }, label: {
                        Label("画像を削除", systemImage: "trash")
                    })
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

#Preview {
    ImageView(userDataStore: .shared, roomDataStore: .shared, listDataStore: .shared, memoDataStore: .shared, imageDataStore: .shared, pathDataStore: .shared)
}
