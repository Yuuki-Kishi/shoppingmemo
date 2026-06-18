//
//  LeaveButton.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/18.
//

import SwiftUI

struct LeaveButton: View {
    private let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "figure.walk.departure")
                .foregroundStyle(Color.red)
                .font(.system(size: 30))
                .frame(width: 70, height: 70)
                .glassEffect(.regular)
                .clipShape(Circle())
        }
        .padding(.trailing, 34)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}

#Preview {
    LeaveButton() {}
}
