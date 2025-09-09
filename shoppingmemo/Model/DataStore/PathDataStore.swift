//
//  PathDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/31.
//

import Foundation

@MainActor
class PathDataStore: ObservableObject {
    static let shared = PathDataStore()
    @Published var navigationPath: [path] = []
    
    enum path {
        case lists, memos, image, myInfo, noticeList, notice
    }
}
