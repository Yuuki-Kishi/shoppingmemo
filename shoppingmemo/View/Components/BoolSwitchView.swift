//
//  BoolSwitchView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/05/14.
//

import SwiftUI

struct BoolSwitchView<Content: View>: View {
    private var isEmpty: Bool
    @Binding private var isLoading: Bool
    private let contentName: String?
    private let bodyContent: AnyView

    init(isEmpty: Bool, isLoading: Binding<Bool> = Binding(get: {false}, set: {_ in}), contentName: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.isEmpty = isEmpty
        self._isLoading = isLoading
        self.contentName = contentName
        self.bodyContent = AnyView(content())
    }
    
    init<Value>(optional: Value?, isLoading: Binding<Bool> = Binding(get: {false}, set: {_ in}), contentName: String? = nil, @ViewBuilder content: @escaping (Value) -> Content) {
        self.isEmpty = optional == nil
        self._isLoading = isLoading
        self.contentName = contentName
        if let optional {
            self.bodyContent = AnyView(content(optional))
        } else {
            self.bodyContent = AnyView(EmptyView())
        }
    }
    
    var body: some View {
        if let contentName {
            if isLoading {
                ProgressView()
                    .scaleEffect(2)
            } else if isEmpty {
                Text("\(contentName)がありません")
            } else {
                bodyContent
            }
        } else if !isEmpty && !isLoading {
            bodyContent
        }
    }
}

#Preview {
    BoolSwitchView(isEmpty: false, isLoading: Binding(get: {false}, set: {_ in}), contentName: "test") { Text("testView") }
}
