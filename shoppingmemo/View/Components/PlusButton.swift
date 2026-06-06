//
//  PlusButton.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/05/14.
//

import SwiftUI

struct PlusButton: View {
    private let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .foregroundStyle(Color.primary)
                .font(.system(size: 30))
                .frame(width: 70, height: 70)
                .background(Color("AccentColor"))
                .clipShape(Circle())
        }
        .padding(.trailing, 34)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}

#Preview {
    PlusButton() {}
}
