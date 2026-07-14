//
//  WatchButton.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/14.
//

import SwiftUI

struct WatchButton: View {
    @EnvironmentObject var watchDataStore: WatchDataStore
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: iconString())
        }

    }
    func action() {
        if watchDataStore.isConnect {
            SessionRepository.sendDisconnect()
        } else {
            SessionRepository.sendNonCheckMemoArray()
        }
    }
    func iconString() -> String {
        if watchDataStore.isConnect {
            "applewatch.slash"
        } else {
            "applewatch.radiowaves.left.and.right"
        }
    }
}

#Preview {
    WatchButton()
}
