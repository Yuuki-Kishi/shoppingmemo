//
//  ImageView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/10.
//

import SwiftUI
import PhotosUI

struct ImageView: View {
    @EnvironmentObject private var memoDataStore: MemoDataStore
    @EnvironmentObject private var imageDataStore: ImageDataStore
    @State private var selectedImage: PhotosPickerItem?
    @State private var photosPickerIsPresented: Bool = false
    @State private var imageInfoViewIsPresented: Bool = false
    @State private var isShowCameraView: Bool = false
    @State private var downloadImageCompleteAlertIsPresented: Bool = false
    @State private var downloadImageFailedAlertIsPresented: Bool = false
    @State private var deleteImageAlertIsPresented: Bool = false
    
    var body: some View {
        ImageDataUnwrapView(imageData: imageDataStore.attachedImage?.imageData, isLoading: imageDataStore.isLoading) { uiImage in
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .zoomable(maxScale: 5)
        } nilContent: {
            Text("ImageView.nilContent.Text")
        }
        .onChange(of: memoDataStore.selectedMemo()?.imageUrl) { _, imageUrl in
            Task { await loadImage(imageUrl: memoDataStore.selectedMemo()?.imageUrl ?? "default") }
        }
        .photosPicker(isPresented: $photosPickerIsPresented, selection: $selectedImage)
        .onChange(of: selectedImage) {
            Task { await imageSelected() }
        }
        .sheet(isPresented: $imageInfoViewIsPresented) {
            ImageInfoView()
                .presentationDetents([.height(200)])
        }
        .fullScreenCover(isPresented: $isShowCameraView) {
            CameraView { imageData in
                Task { await uploadImageData(data: imageData) }
            }
            .ignoresSafeArea()
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
        .alert("ImageView.downloadCompleteAlert.title", isPresented: $downloadImageCompleteAlertIsPresented) {
            OKButton()
        } message: {
            Text("ImageView.downloadCompleteAlert.message")
        }
        .alert("ImageView.downloadFailedAlert.title", isPresented: $downloadImageFailedAlertIsPresented) {
            OKButton()
        } message: {
            Text("ImageView.downloadFailedAlert.message")
        }
        .alert("ImageView.deleteImageAlert.title", isPresented: $deleteImageAlertIsPresented) {
            deleteImageAlertActions()
        } message: {
            Text("ImageView.deleteImageAlert.message")
        }
        .navigationTitle(memoDataStore.selectedMemo()?.memoName ?? "ImageView.navigationTitle.unknownMemoName")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            Task { await loadImage(imageUrl: memoDataStore.selectedMemo()?.imageUrl ?? "default") }
            CustomImageRepository.clearImage()
        }
    }
    func loadImage(imageUrl: String) async {
        imageDataStore.isLoading = true
        await CustomImageRepository.getImage(imageUrl: imageUrl)
        imageDataStore.isLoading = false
    }
    func imageSelected() async {
        guard let data = try? await selectedImage?.loadTransferable(type: Data.self) else { return }
        await uploadImageData(data: data)
    }
    func uploadImageData(data: Data) async {
        imageDataStore.isLoading = true
        await CustomImageRepository.createImage(imageData: data)
    }
    func toolBarMenu() -> some View {
        ZStack {
            if memoDataStore.selectedMemo()?.imageUrl == "default" {
                Menu {
                    Button {
                        photosPickerIsPresented = true
                    } label: {
                        Label("ImageView.toolBarMenu.addImageFromAlbum.title", systemImage: "photo.stack")
                    }
                    Button {
                        isShowCameraView = true
                    } label: {
                        Label("ImageView.toolBarMenu.addImageFromCamera.title", systemImage: "camera")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            } else {
                Menu {
                    Button {
                        imageInfoViewIsPresented = true
                    } label: {
                        Label("ImageView.toolBarMenu.imageInfo.title", systemImage: "info.circle")
                    }
                    Button {
                        photosPickerIsPresented = true
                    } label: {
                        Label("ImageView.toolBarMenu.changeImageFromAlbum.title", systemImage: "photo.on.rectangle.angled")
                    }
                    Button {
                        isShowCameraView = true
                    } label: {
                        Label("ImageView.toolBarMenu.changeImageFromCamera.title", systemImage: "camera")
                    }
                    Button {
                        downloadImage()
                    } label: {
                        Label("ImageView.toolBarMenu.downloadImage.title", systemImage: "square.and.arrow.down")
                    }
                    Divider()
                    Button(role: .destructive) {
                        deleteImageAlertIsPresented = true
                    } label: {
                        Label("ImageView.toolBarMenu.deleteImage.title", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    @ViewBuilder
    func deleteImageAlertActions() -> some View {
        CancelButton()
        DeleteButton {
            Task { await CustomImageRepository.deleteImage() }
        }
    }
    func downloadImage() {
        Task {
            await CustomImageRepository.downloadImage {
                downloadImageCompleteAlertIsPresented = true
            } failure: {
                downloadImageFailedAlertIsPresented = true
            }
        }
    }
}

#Preview {
    ImageView()
}
