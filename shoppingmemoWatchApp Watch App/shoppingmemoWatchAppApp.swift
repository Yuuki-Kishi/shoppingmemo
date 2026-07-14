//
//  shoppingmemoWatchAppApp.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/11.
//

import SwiftUI

@main
struct shoppingmemoWatchApp_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(UserDataStore.shared)
        .environmentObject(MemoDataStore.shared)
        .environmentObject(WatchDataStore.shared)
        .environmentObject(PathDataStore.shared)
    }
}
