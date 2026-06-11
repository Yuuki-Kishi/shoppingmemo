//
//  BoolSwitchView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/11.
//

import SwiftUI

struct BoolSwitchView<Content: View, EmptyContent: View>: View {
    private let isEmpty: Bool
    private let isLoading: Bool
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let emptyContent: () -> EmptyContent
    
    init(isEmpty: Bool = false, isLoading: Bool = false, @ViewBuilder content: @escaping () -> Content, @ViewBuilder emptyContent: @escaping () -> EmptyContent) {
        self.isEmpty = isEmpty
        self.isLoading = isLoading
        self.content = content
        self.emptyContent = emptyContent
    }

    var body: some View {
        if isLoading {
            ProgressView()
                .scaleEffect(2)
        } else if isEmpty {
            emptyContent()
        } else {
            content()
        }
    }
}

#Preview {
    BoolSwitchView() {} emptyContent: {}
}
