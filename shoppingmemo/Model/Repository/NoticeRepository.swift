//
//  NoticeRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/18.
//

import Foundation
import FirebaseFirestore

@MainActor
class NoticeRepository {
    static let noticeDataStore: NoticeDataStore = .shared
    
    //create
    
    //check
    
    //get
    
    //update
    
    //delete
    static func clearNotices() {
        noticeDataStore.noticeArray.removeAll()
    }
    
    //observe
    static func observeNotices(completion: @escaping () -> Void) {
        Firestore.firestore().collection("Notices").addSnapshotListener() { querySnapshot, error in
            do {
                guard let documentChanges = querySnapshot?.documentChanges else {
                    print("Failed to get documentChanges")
                    completion()
                    return
                }
                for documentChange in documentChanges {
                    let notice = try documentChange.document.data(as: Notice.self)
                    switch documentChange.type {
                    case .added:
                        noticeDataStore.noticeArray.append(noDuplicate: notice)
                    case .modified:
                        noticeDataStore.noticeArray.append(noDuplicate: notice)
                    case .removed:
                        noticeDataStore.noticeArray.remove(notice: notice)
                        if notice.noticeId == noticeDataStore.noticeArray.selected?.noticeId {
                            noticeDataStore.selectedNoticeId = nil
                            NavigationRepository.removeAllViews()
                        }
                    }
                }
                noticeDataStore.noticeArray.sort { $0.creationDate > $1.creationDate }
                completion()
            } catch {
                print(error.localizedDescription)
                completion()
            }
        }
    }
}
