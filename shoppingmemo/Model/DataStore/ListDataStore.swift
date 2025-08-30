//
//  ListDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/31.
//

import Foundation

class ListDataStore: ObservableObject {
    static let shared = ListDataStore()
    @Published var lists: [List] = []
    @Published var selectedList: List? = nil
}
