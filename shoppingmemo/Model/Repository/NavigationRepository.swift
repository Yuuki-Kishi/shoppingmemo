//
//  NavigationRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/04.
//

import Foundation

@MainActor
class NavigationRepository {
    static let pathDataStore: PathDataStore = .shared
    
    static func removeAllViews() {
        pathDataStore.navigationPath.removeAll()
    }
    
    static func removeViews(dest: PathDataStore.path) {
        guard let index = pathDataStore.navigationPath.firstIndex(of: dest) else { return }
        let maxLoop = pathDataStore.navigationPath.count - index - 1
        for _ in 0 ..< maxLoop {
            pathDataStore.navigationPath.removeLast()
        }
    }
}
