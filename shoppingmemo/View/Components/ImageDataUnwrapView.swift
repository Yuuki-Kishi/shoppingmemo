//
//  ImageDataUnwrapView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/22.
//

import SwiftUI

struct ImageDataUnwrapView<Content: View, NilContent: View>: View {
    private let imageData: Data?
    private let isLoading: Bool
    private let content: (UIImage) -> Content
    private let nilContent: () -> NilContent
    
    init(imageData: Data?, isLoading: Bool = false, @ViewBuilder content: @escaping (UIImage) -> Content, @ViewBuilder nilContent: @escaping () -> NilContent) {
        self.imageData = imageData
        self.isLoading = isLoading
        self.content = content
        self.nilContent = nilContent
    }
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let imageData, let image = UIImage(data: imageData) {
                content(image)
            } else {
                nilContent()
            }
        }
    }
}

#Preview {
    ImageDataUnwrapView(imageData: Data()) { uiImage in } nilContent: {}
}
