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
    
    static func removeViews(numberOfLeave: Int) {
        let maxLoop = pathDataStore.navigationPath.count - numberOfLeave
        for _ in 0 ..< maxLoop {
            pathDataStore.navigationPath.removeLast()
        }
    }
}
