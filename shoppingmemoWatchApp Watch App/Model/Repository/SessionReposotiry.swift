//
//  SessionReposotiry.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/13.
//

import Foundation
import WatchConnectivity

@MainActor
class SessionRepository {
    static let userDataStore: UserDataStore = .shared
    
    static func sendMessage() {
        let message: [String: Any] = ["test": "testFromAppleWatch"]
        self.userDataStore.viewModel.session.sendMessage(message, replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }
}
