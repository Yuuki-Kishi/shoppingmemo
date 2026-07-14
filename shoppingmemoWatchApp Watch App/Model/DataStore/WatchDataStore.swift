//
//  WatchDataStore.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/14.
//

import Foundation
import Combine

@MainActor
class WatchDataStore: ObservableObject {
    static let shared = WatchDataStore()
    @Published var isReachable: Bool = false
    @Published var isConnect: Bool = false
}
