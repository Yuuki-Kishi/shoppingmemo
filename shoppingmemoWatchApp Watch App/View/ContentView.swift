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
            MemosView()
        } else if watchDataStore.isReachable {
            IconLabelView(iconString: "iphone.gen3.radiowaves.left.and.right", labelText: "WatchApp.IconLabelView.labelText")
        } else {
            IconLabelView(iconString: "iphone.gen3.slash", labelText: "WatchApp.IconLabelView.labelText")
        }
    }
}

#Preview {
    ContentView()
}
