//
//  PathDataStore.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/13.
//

import Foundation
import Combine

@MainActor
class PathDataStore: ObservableObject {
    static let shared = PathDataStore()
    @Published var navigationPath: [path] = []
    
    enum path {
        case unknown
    }
}
