//
//  ClearTextField.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/05/21.
//

import SwiftUI

struct ClearTextField: View {
    @Binding private var text: String
    @FocusState.Binding var focus: Bool
    private let action: () -> Void
    
    init(text: Binding<String>, focus: FocusState<Bool>.Binding, action: @escaping () -> Void) {
        self._text = text
        self._focus = focus
        self.action = action
    }
    
    var body: some View {
        VStack {
            TextField("アイテムを追加", text: $text, onCommit: action)
                .padding()
                .glassEffect(.regular.tint(.accentColor))
                .tint(.blue)
                .focused($focus)
                .padding(.horizontal)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
//    ClearTextField(text: Binding(get: { "" }, set: {_ in}), focus: true) {}
}
