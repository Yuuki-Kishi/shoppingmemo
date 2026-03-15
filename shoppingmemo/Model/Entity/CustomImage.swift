//
//  Image.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/10.
//

import Foundation

struct CustomImage: Hashable, Identifiable, Equatable {
    static func == (lhs: CustomImage, rhs: CustomImage) -> Bool {
        lhs.imageUrl == rhs.imageUrl
    }
    
    var id = UUID()
    var imageUrl: String
    var imageData: Data
    var uploadTime: Date
    var uploadUserId: String
    
    init(imageUrl: String, imageData: Data, uploadTime: Date, uploadUserId: String) {
        self.imageUrl = imageUrl
        self.imageData = imageData
        self.uploadTime = uploadTime
        self.uploadUserId = uploadUserId
    }
    
    init() {
        self.imageUrl = "unknownImageUrl"
        self.imageData = Data()
        self.uploadTime = Date()
        self.uploadUserId = "unknownUserId"
    }
}
