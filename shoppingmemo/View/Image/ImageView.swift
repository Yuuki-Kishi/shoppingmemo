//
//  ImageView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/10.
//

import SwiftUI
import PhotosUI

struct ImageView: View {
    @ObservedObject var memoDataStore: MemoDataStore
    @ObservedObject var imageDataStore: ImageDataStore
    @ObservedObject var pathDataStore: PathDataStore
    
    @State private var selectedImage: PhotosPickerItem?
    
    @State private var photosPickerIsPresented: Bool = false
    @State private var imageInfoViewIsPresented: Bool = false
    @State private var deleteImageAlertIsPresented: Bool = false
    
    var body: some View {
        ZStack {
            if imageDataStore.isLoading {
                ProgressView()
                    .scaleEffect(2)
            } else {
                if let uiImage = getUIImage() {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("表示できる画像がありません")
                }
            }
        }
        .photosPicker(isPresented: $photosPickerIsPresented, selection: $selectedImage)
        .onChange(of: selectedImage) {
            imageDataStore.isLoading = true
            Task { await CustomImageRepository.createImage(selectedImage: selectedImage) }
        }
        .sheet(isPresented: $imageInfoViewIsPresented) {
            ImageInfoView(memoDataStore: memoDataStore, imageDataStore: imageDataStore)
                .presentationDetents([.height(190)])
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                toolBarMenu()
            })
        }
        .alert("画像を削除しますか？", isPresented: $deleteImageAlertIsPresented, actions: {
            deleteImageAlertActions()
        }, message: {
            Text("この操作は取り消すことができません。")
        })
        .navigationTitle(memoDataStore.selectedMemo?.memoName ?? "不明なメモ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            imageDataStore.isLoading = true
            CustomImageRepository.observeImageUrl()
        }
    }
    func getUIImage() -> UIImage? {
        if let imageData = imageDataStore.attachedImage?.imageData {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    }
    func toolBarMenu() -> some View {
        ZStack {
            if imageDataStore.attachedImage == nil {
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
                        imageInfoViewIsPresented = true
                    }, label: {
                        Label("情報", systemImage: "info.circle")
                    })
                    Button(action: {
                        photosPickerIsPresented = true
                    }, label: {
                        Label("アルバムから変更", systemImage: "photo.on.rectangle.angled")
                    })
                    Button(action: {
                        
                    }, label: {
                        Label("撮影して変更", systemImage: "camera")
                    })
                    Divider()
                    Button(role: .destructive, action: {
                        deleteImageAlertIsPresented = true
                    }, label: {
                        Label("画像を削除", systemImage: "trash")
                    })
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    @ViewBuilder
    func deleteImageAlertActions() -> some View {
        Button(role: .cancel, action: {}, label: {
            Text("キャンセル")
        })
        Button(role: .destructive, action: {
            Task { await CustomImageRepository.deleteImage() }
        }, label: {
            Text("削除")
        })
    }
}

#Preview {
    ImageView(memoDataStore: .shared, imageDataStore: .shared, pathDataStore: .shared)
}
