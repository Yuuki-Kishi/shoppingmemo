//
//  MemoDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/31.
//

import Foundation

@MainActor
class MemoDataStore: ObservableObject {
    static let shared = MemoDataStore()
    @Published var memos: [Memo] = []
    @Published var selectedMemo: Memo? = nil
}
