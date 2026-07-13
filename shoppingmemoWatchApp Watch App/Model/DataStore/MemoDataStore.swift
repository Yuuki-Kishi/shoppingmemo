//
//  MemoDataStore.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/12.
//

import Foundation
import Combine

@MainActor
class MemoDataStore: ObservableObject {
    static let shared = MemoDataStore()
    @Published var listName: String = ""
    @Published var memoArray: [Memo] = []
}
