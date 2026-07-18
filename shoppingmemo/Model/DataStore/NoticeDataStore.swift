//
//  noticeDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/18.
//

import Foundation

class NoticeDataStore: ObservableObject {
    static let shared = NoticeDataStore()
    @Published var noticeArray: [Notice] = []
    @Published var selectedNoticeId: String? = nil
    @Published var isLoading: Bool = false
}
