//
//  RoomDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/31.
//

import Foundation

class RoomDataStore: ObservableObject {
    static let shared = RoomDataStore()
    @Published var rooms: [Room] = []
    @Published var selectedRoom: Room? = nil
}
