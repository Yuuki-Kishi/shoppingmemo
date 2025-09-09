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
}
