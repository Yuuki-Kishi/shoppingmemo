//
//  ListDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/31.
//

import Foundation

@MainActor
class ListDataStore: ObservableObject {
    static let shared = ListDataStore()
    @Published var listArray: [CustomList] = []
    @Published var selectedList: CustomList? = nil
    @Published var isLoading: Bool = false
    @Published var listSort: SortModeEnum = .ascending
    
    enum SortModeEnum: String {
        case ascending, descending, newest, custom
    }
}
