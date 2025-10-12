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
    var memoId: String
    var imageData: Data
    var uploadTime: Date
    var uploadUserId: String
    
    init(memoId: String, imageData: Data, uploadTime: Date, uploadUserId: String) {
        self.memoId = memoId
        self.imageData = imageData
        self.uploadTime = uploadTime
        self.uploadUserId = uploadUserId
    }
    
    init(){
        self.memoId = "unknownMemoId"
        self.imageData = Data()
        self.uploadTime = Date()
        self.uploadUserId = "unknownUserId"
    }
}
