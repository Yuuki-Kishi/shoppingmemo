//
//  WatchViewModel.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/13.
//

import Foundation
import WatchConnectivity

@MainActor
final class WatchViewModel: NSObject {
    let watchDataStore: WatchDataStore = .shared
    let memoDataStore: MemoDataStore = .shared
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
}

extension WatchViewModel: @MainActor WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            Task { @MainActor in
                watchDataStore.isReachable = session.isReachable
            }
            print("The session has completed activation.")
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            watchDataStore.isReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task { @MainActor in
            guard let status = message["status"] as? String else { replyHandler(["isSuccess": false]); return }
            switch status {
            case "sendData":
                do {
                    guard let listName = message["listName"] as? String else { replyHandler(["isSuccess": false]); return }
                    guard let data = message["memoArray"] as? Data else { replyHandler(["isSuccess": false]); return }
                    let memoArray = try JSONDecoder().decode([Memo].self, from: data)
                    memoDataStore.listName = listName
                    memoDataStore.memoArray = memoArray
                    watchDataStore.isConnect = true
                    replyHandler(["isSuccess": true])
                } catch {
                    print(error.localizedDescription)
                    replyHandler(["isSuccess": false])
                }
            case "disconnect":
                watchDataStore.isConnect = false
                replyHandler(["isSuccess": true])
            default:
                replyHandler(["reply": false])
            }
        }
    }
}
