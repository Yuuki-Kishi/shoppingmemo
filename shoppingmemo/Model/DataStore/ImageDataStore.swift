//
//  ImageDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/10.
//

import Foundation

@MainActor
class ImageDataStore: ObservableObject {
    static let shared = ImageDataStore()
    @Published var selectedMemoImage: CustomImage? = nil
    @Published var userNameResult: Result<String?, Error>? = nil
    @Published var uploadUserName: String? = nil
}
