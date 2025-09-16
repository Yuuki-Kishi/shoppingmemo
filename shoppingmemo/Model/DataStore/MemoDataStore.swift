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
    @Published var nonCheckMemoArray: [Memo] = []
    @Published var checkedMemoArray: [Memo] = []
    @Published var selectedMemo: Memo? = nil
    @Published var isShowChecked: Bool = false
    @Published var nonCheckSort: SortModeEnum = .ascending
    @Published var checkedSort: SortModeEnum = .ascending
    
    enum SortModeEnum: String {
        case ascending, descending, newest, custom
    }
}
