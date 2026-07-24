//
//  DeleteIconButton.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/22.
//

import SwiftUI

struct DeleteIconButton: View {
    private let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(role: .destructive, action: action) {
            Image(systemName: "trash")
        }
    }
}

#Preview {
    DeleteIconButton() {}
}
