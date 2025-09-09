//
//  Memo.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/29.
//

import Foundation

struct Memo: Codable, Hashable, Identifiable, Equatable {
    static func == (lhs: Memo, rhs: Memo) -> Bool {
        return lhs.memoId == rhs.memoId
    }
    
    var id = UUID()
    var memoId: String
    var memoName: String
    var isChecked: Bool
    var creationTime: Date
    var checkedTime: Date
    var nonCheckOrder: Int
    var checkedOrder: Int
    var imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case memoId, memoName, isChecked, creationTime, checkedTime, nonCheckOrder, checkedOrder, imageUrl
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.memoId = try container.decode(String.self, forKey: .memoId)
        self.memoName = try container.decode(String.self, forKey: .memoName)
        self.isChecked = try container.decode(Bool.self, forKey: .isChecked)
        let formatter = ISO8601DateFormatter()
        let creationTimeString = try container.decode(String.self, forKey: .creationTime)
        if let date = formatter.date(from: creationTimeString) {
            self.creationTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .creationTime, in: container, debugDescription: "Failed to decode creationTime.")
        }
        let checkedTimeString = try container.decode(String.self, forKey: .checkedTime)
        if let date = formatter.date(from: checkedTimeString) {
            self.checkedTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .checkedTime, in: container, debugDescription: "Failed to decode checkedTime.")
        }
        self.nonCheckOrder = try container.decode(Int.self, forKey: .nonCheckOrder)
        self.checkedOrder = try container.decode(Int.self, forKey: .checkedOrder)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.memoId, forKey: .memoId)
        try container.encode(self.memoName, forKey: .memoName)
        try container.encode(self.isChecked, forKey: .isChecked)
        let formatter = ISO8601DateFormatter()
        let creationTimeString = formatter.string(from: self.creationTime)
        try container.encode(creationTimeString, forKey: .creationTime)
        let checkedTimeString = formatter.string(from: self.checkedTime)
        try container.encode(checkedTimeString, forKey: .checkedTime)
        try container.encode(self.nonCheckOrder, forKey: .nonCheckOrder)
        try container.encode(self.checkedOrder, forKey: .checkedOrder)
        try container.encode(self.imageUrl, forKey: .imageUrl)
    }
    
    init(memoId: String, memoName: String, isChecked: Bool, creationTime: Date, checkedTime: Date, nonCheckOrder: Int, checkedOrder: Int, imageUrl: String) {
        self.memoId = memoId
        self.memoName = memoName
        self.isChecked = isChecked
        self.creationTime = creationTime
        self.checkedTime = checkedTime
        self.nonCheckOrder = nonCheckOrder
        self.checkedOrder = checkedOrder
        self.imageUrl = imageUrl
    }
    
    init() {
        self.memoId = "unknownMemoId"
        self.memoName = "unknownMemoName"
        self.isChecked = false
        self.creationTime = Date()
        self.checkedTime = Date()
        self.nonCheckOrder = 0
        self.checkedOrder = 0
        self.imageUrl = "default"
    }
}
