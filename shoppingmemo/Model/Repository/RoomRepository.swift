//
//  RoomRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/16.
//

import Foundation
import FirebaseFirestore

@MainActor
class RoomRepository {
    static let userDataStore = UserDataStore.shared
    static let roomDataStore = RoomDataStore.shared
    
    //create
    
    //check
    
    //get
    static func getBelongRooms() async -> [Room] {
        guard let authority = userDataStore.signInUser?.authority else { return [] }
        
    }
    
    //update
    
    //delete
    
    //observe
}
