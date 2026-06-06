//
//  ToggleLabel.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/05/21.
//

import SwiftUI

struct ToggleLabel: View {
    private let title: String
    private let systemImage: String
    private let get: () -> Bool
    
    init(title: String, systemImage: String, get: @escaping () -> Bool) {
        self.title = title
        self.systemImage = systemImage
        self.get = get
    }
    
    var body: some View {
        Toggle(isOn: isOn()) {
            Label(title, systemImage: systemImage)
        }
    }
    func isOn() -> Binding<Bool> {
        Binding(get: get, set: {_ in})

    }
}

#Preview {
    ToggleLabel(title: "タイトル昇順", systemImage: "a.circle") { true }
}
