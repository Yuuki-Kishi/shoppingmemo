//
//  ImageView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/10.
//

import SwiftUI
import PhotosUI

struct ImageView: View {
    @StateObject var memoDataStore: MemoDataStore = .shared
    @StateObject var imageDataStore: ImageDataStore = .shared
    @StateObject var pathDataStore: PathDataStore = .shared
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var uiImage: UIImage?
    
    @State private var photosPickerIsPresented: Bool = false
    @State private var imageInfoViewIsPresented: Bool = false
    @State private var deleteImageAlertIsPresented: Bool = false
    
    var body: some View {
        ZStack {
            BoolSwitchView(optional: uiImage, isLoading: $imageDataStore.isLoading, contentName: "画像") { uiImage in
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
            .task {
                await loadImage(imageUrl: memoDataStore.selectedMemo?.imageUrl ?? "default")
            }
        }
        .onChange(of: memoDataStore.selectedMemo?.imageUrl) { _, imageUrl in
            Task { await loadImage(imageUrl: memoDataStore.selectedMemo?.imageUrl ?? "default") }
        }
        .photosPicker(isPresented: $photosPickerIsPresented, selection: $selectedImage)
        .onChange(of: selectedImage) {
            imageDataStore.isLoading = true
            Task { await CustomImageRepository.createImage(selectedImage: selectedImage) }
        }
        .sheet(isPresented: $imageInfoViewIsPresented) {
            ImageInfoView()
                .presentationDetents([.height(200)])
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HelpButton()
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                toolBarMenu()
            }
        }
        .alert("画像を削除しますか？", isPresented: $deleteImageAlertIsPresented) {
            deleteImageAlertActions()
        } message: {
            Text("この操作は取り消すことができません。")
        }
        .navigationTitle(memoDataStore.selectedMemo?.memoName ?? "不明なメモ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            CustomImageRepository.clearImage()
        }
    }
    func loadImage(imageUrl: String) async {
        if let imageData = imageDataStore.attachedImage?.imageData {
            uiImage = UIImage(data: imageData)
            return
        }
        imageDataStore.isLoading = true
        defer { imageDataStore.isLoading = false }
        await CustomImageRepository.getImage(imageUrl: imageUrl)
        guard let imageData = imageDataStore.attachedImage?.imageData else { return }
        uiImage = UIImage(data: imageData)
    }
    func toolBarMenu() -> some View {
        ZStack {
            if memoDataStore.selectedMemo?.imageUrl == "default" {
                Menu {
                    Button {
                        photosPickerIsPresented = true
                    } label: {
                        Label("アルバムから追加", systemImage: "photo.stack")
                    }
                    Button {
                        
                    } label: {
                        Label("撮影して追加", systemImage: "camera")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            } else {
                Menu {
                    Button {
                        imageInfoViewIsPresented = true
                    } label: {
                        Label("情報", systemImage: "info.circle")
                    }
                    Button {
                        photosPickerIsPresented = true
                    } label: {
                        Label("アルバムから変更", systemImage: "photo.on.rectangle.angled")
                    }
                    Button {
                        
                    } label: {
                        Label("撮影して変更", systemImage: "camera")
                    }
                    Divider()
                    Button(role: .destructive) {
                        deleteImageAlertIsPresented = true
                    } label: {
                        Label("画像を削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    @ViewBuilder
    func deleteImageAlertActions() -> some View {
        Button(role: .cancel) {} label: {
            Text("キャンセル")
        }
        Button(role: .destructive) {
            Task { await CustomImageRepository.deleteImage() }
        } label: {
            Text("削除")
        }
    }
}

#Preview {
    ImageView()
}
