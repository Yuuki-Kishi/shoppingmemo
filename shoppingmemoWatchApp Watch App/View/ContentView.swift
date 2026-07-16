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
        if watchDataStore.isConnect {
            MemoView()
        } else if watchDataStore.isReachable {
            IconLabelView(iconString: "iphone.gen3.radiowaves.left.and.right", labelText: "接続準備完了")
        } else {
            IconLabelView(iconString: "iphone.gen3.slash", labelText: "接続が切れています")
        }
    }
}

#Preview {
    ContentView()
}
