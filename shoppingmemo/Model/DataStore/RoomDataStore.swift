//
//  RoomDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/31.
//

import Foundation

@MainActor
class RoomDataStore: ObservableObject {
    static let shared = RoomDataStore()
    @Published var roomArray: [Room] = []
    @Published var selectedRoomId: String? = nil
    @Published var isLoading: Bool = false
}
