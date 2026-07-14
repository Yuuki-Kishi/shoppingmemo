//
//  SessionRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/13.
//

import Foundation
import WatchConnectivity

@MainActor
class SessionRepository {
    static let userDataStore: UserDataStore = .shared
    static let listDataStore: ListDataStore = .shared
    static let watchDataStore: WatchDataStore = .shared
    static let memoDataStore: MemoDataStore = .shared
    
    static func sendMessage(message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        userDataStore.viewModel.session.sendMessage(message, replyHandler: replyHandler) { error in
            print(error.localizedDescription)
        }
    }
    
    static func sendNonCheckMemoArray() {
        do {
            guard let listName = listDataStore.listArray.selected?.listName else { return }
            let data = try JSONEncoder().encode(memoDataStore.nonCheckMemoArray)
            let message: [String: Any] = ["status": "sendData", "listName": listName, "memoArray": data]
            sendMessage(message: message) { reply in
                guard let isSuccess = reply["isSuccess"] as? Bool else { return }
                Task { @MainActor in
                    watchDataStore.isConnect = isSuccess
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func sendDisconnect() {
        let message: [String: Any] = ["status": "disconnect"]
        sendMessage(message: message) { reply in
            guard let isSuccess = reply["isSuccess"] as? Bool else { return }
            Task { @MainActor in
                watchDataStore.isConnect = !isSuccess
            }
        }
    }
}
