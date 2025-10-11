//
//  Image.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/10.
//

import Foundation

struct CustomImage: Hashable, Identifiable, Equatable {
    static func == (lhs: CustomImage, rhs: CustomImage) -> Bool {
        lhs.memoId == rhs.memoId
    }
    
    var id = UUID()
    var roomId: String
    var listId: String
    var memoId: String
    var imageData: Data
    var lastUpdateTime: Date
    
    init(roomId: String, listId: String, memoId: String, imageData: Data, lastUpdateTime: Date) {
        self.roomId = roomId
        self.listId = listId
        self.memoId = memoId
        self.imageData = imageData
        self.lastUpdateTime = lastUpdateTime
    }
    
    init() {
        self.roomId = "unknownRoomId"
        self.listId = "unknownListId"
        self.memoId = "unknownMemoId"
        self.imageData = Data()
        self.lastUpdateTime = Date()
    }
}
