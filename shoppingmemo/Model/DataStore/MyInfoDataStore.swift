//
//  MyInfoDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import Foundation

@MainActor
class MyInfoDataStore: ObservableObject {
    static let shared = MyInfoDataStore()
    @Published var newUserName: String = ""
    @Published var renameUserNameAlertIsPresent: Bool = false
    @Published var copiedUserIdAlertIsPresent: Bool = false
}
