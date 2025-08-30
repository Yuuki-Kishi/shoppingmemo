//
//  PathDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/31.
//

import Foundation

class PathDataStore: ObservableObject {
    static let shared = PathDataStore()
    @Published var navigationPath: [path] = []
    
    enum path {
        case rooms, lists, memos, image
    }
}
