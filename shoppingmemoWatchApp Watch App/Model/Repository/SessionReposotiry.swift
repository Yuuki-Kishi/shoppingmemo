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
    static let watchDataStore: WatchDataStore = .shared
    
    static func sendMessage(message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        userDataStore.viewModel.session.sendMessage(message, replyHandler: replyHandler) { error in
            print(error.localizedDescription)
        }
    }
    
//    static func sendIsConnect(isConnect: Bool) {
//        let message: [String: Any] = ["status": "isConnect", "isConnect": isConnect]
//        sendMessage(message: message) { reply in
//            guard let isConnect = reply["isSuccess"] as? Bool else { return }
//            Task { @MainActor in
//                watchDataStore.isConnect = isConnect
//            }
//        }
//    }
    
    static func sendCheck(memoId: String) {
        let message: [String: Any] = ["status": "check", "memoId": memoId]
        sendMessage(message: message) { reply in
            guard let isSuccess = reply["isSuccess"] as? Bool else { return }
            print("isSuccess:", isSuccess)
        }
    }
}
