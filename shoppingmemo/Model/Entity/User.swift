//
//  User.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/25.
//

import Foundation
import SwiftUI

struct User: Codable, Hashable, Identifiable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    var id = UUID()
    var userId: String
    var userName: String
    var email: String
    var creationTime: Date
    var currentVersion: String
    var iOSVersion: String
    var noticeCheckedTime: Date
    
    enum CodingKeys: String, CodingKey {
        case userId, userName, email, creationTime, currentVersion, iOSVersion, noticeCheckedTime
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.email = try container.decode(String.self, forKey: .email)
        let formatter = ISO8601DateFormatter()
        let creationTimeString = try container.decode(String.self, forKey: .creationTime)
        if let date = formatter.date(from: creationTimeString) {
            self.creationTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .creationTime, in: container, debugDescription: "Failed to decode creationDate.")
        }
        self.currentVersion = try container.decode(String.self, forKey: .currentVersion)
        self.iOSVersion = try container.decode(String.self, forKey: .iOSVersion)
        let noticeCheckedTimeString = try container.decode(String.self, forKey: .creationTime)
        if let date = formatter.date(from: noticeCheckedTimeString) {
            self.noticeCheckedTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .noticeCheckedTime, in: container, debugDescription: "Failed to decode creationDate.")
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(userName, forKey: .userName)
        let formatter = ISO8601DateFormatter()
        let creationTimeString = formatter.string(from: creationTime)
        try container.encode(creationTimeString, forKey: .creationTime)
        try container.encode(email, forKey: .email)
        try container.encode(currentVersion, forKey: .currentVersion)
        try container.encode(iOSVersion, forKey: .iOSVersion)
        let noticeCheckedTimeString = formatter.string(from: noticeCheckedTime)
        try container.encode(noticeCheckedTimeString, forKey: .noticeCheckedTime)
    }
    
    init(userId: String, userName: String, email: String, creationTime: Date, currentVersion: String, iOSVersion: String, noticeCheckedTime: Date, authorities: [Authority]) {
        self.userId = userId
        self.userName = userName
        self.email = email
        self.creationTime = creationTime
        self.currentVersion = currentVersion
        self.iOSVersion = iOSVersion
        self.noticeCheckedTime = noticeCheckedTime
    }
    
    init(userId: String, email: String, creationTime: Date) {
        self.userId = userId
        self.userName = "未設定"
        self.email = email
        self.creationTime = creationTime
        let AppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "3.0"
        self.currentVersion = AppVersion
        let iOSVersion = UIDevice.current.systemVersion
        self.iOSVersion = iOSVersion
        self.noticeCheckedTime = ISO8601DateFormatter().date(from: "2001-01-01T00:00:00Z") ?? Date()
    }
    
    init() {
        self.userId = "unknownUserId"
        self.userName = "unknownUserName"
        self.email = "unknownUserEmail"
        self.creationTime = Date()
        self.currentVersion = "unknownVersion"
        self.iOSVersion = "unknownVersion"
        self.noticeCheckedTime = Date()
    }
}
