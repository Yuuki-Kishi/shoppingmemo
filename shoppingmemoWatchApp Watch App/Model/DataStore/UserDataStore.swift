//
//  UserDataStore.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/13.
//

import Foundation
import Combine

class UserDataStore: ObservableObject {
    static let shared = UserDataStore()
    @Published var viewModel = WatchViewModel()
    @Published var isReachable: Bool = false
}
