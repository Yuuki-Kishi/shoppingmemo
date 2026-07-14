//
//  iPhoneViewModel.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/13.
//

import Foundation
import WatchConnectivity

@MainActor
final class iPhoneViewModel: NSObject {
    let watchDataStore: WatchDataStore = .shared
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
}

extension iPhoneViewModel: @MainActor WCSessionDelegate {
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
        watchDataStore.isReachable = session.isReachable
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task { @MainActor in
            guard let status = message["status"] as? String else { replyHandler(["isSuccess": false]); return }
            switch status {
//            case "isConnect":
//                guard let isConnect = message["isConnect"] as? Bool else { replyHandler(["isSuccess": false]); return }
//                watchDataStore.isConnect = isConnect
//                replyHandler(["isSuccess": true])
            case "check":
                guard let memoId = message["memoId"] as? String else { replyHandler(["isSuccess": false]); return }
                await MemoRepository.updateIsChecked(memoId: memoId, newIsChecked: true)
                replyHandler(["isSuccess": true])
            default:
                replyHandler(["isSuccess": false])
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
}
