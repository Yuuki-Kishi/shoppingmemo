//
//  OKButton.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/21.
//

import SwiftUI

struct OKButton: View {
    private let action: () -> Void
    
    init(action: @escaping () -> Void = {}) {
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text("OKButton.label")
        }
    }
}

#Preview {
    OKButton() {}
}
