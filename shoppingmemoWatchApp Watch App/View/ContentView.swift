//
//  ContentView.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/11.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    
    var body: some View {
//        Button {
//            SessionRepository.sendMessage()
//        } label: {
//            Image(systemName: "paperplane")
//        }
        if userDataStore.isReachable {
            MemoView()
        } else {
            IconLabelView(iconString: "iPhone.gen3.radiowave.left.and.right", labelText: "接続準備完了")
        }
    }
}

#Preview {
    ContentView()
}
