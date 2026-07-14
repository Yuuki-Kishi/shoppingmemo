//
//  ContentView.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/11.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var watchDataStore: WatchDataStore
    
    var body: some View {
//        Button {
//            SessionRepository.sendMessage()
//        } label: {
//            Image(systemName: "paperplane")
//        }
        if watchDataStore.isConnect {
            MemoView()
        } else if watchDataStore.isReachable {
            IconLabelView(iconString: "iphone.gen3.radiowaves.left.and.right", labelText: "接続準備完了")
        } else {
            
        }
    }
}

#Preview {
    ContentView()
}
