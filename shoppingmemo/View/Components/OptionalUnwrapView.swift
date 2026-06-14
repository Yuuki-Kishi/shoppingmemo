//
//  BoolSwitchView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/05/14.
//

import SwiftUI

struct OptionalUnwrapView<Value, Content: View, NilContent: View>: View {
    let optional: Value?
    let isLoading: Bool
    let content: (Value) -> Content
    let nilContent: () -> NilContent

    init(optional: Value?, isLoading: Bool = false, @ViewBuilder content: @escaping (Value) -> Content, @ViewBuilder nilContent: @escaping () -> NilContent) {
        self.optional = optional
        self.isLoading = isLoading
        self.content = content
        self.nilContent = nilContent
    }

    var body: some View {
        if isLoading {
            ProgressView()
        } else if let value = optional {
            content(value)
        } else {
            nilContent()
        }
    }
}

#Preview {
    OptionalUnwrapView(optional: nil as UIImage?) {_ in} nilContent: {}
}
