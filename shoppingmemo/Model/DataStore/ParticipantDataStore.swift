//
//  ParticipantDataStore.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import Foundation

@MainActor
class ParticipantDataStore: ObservableObject {
    static let shared = ParticipantDataStore()
    @Published var administrators: [Participant] = []
    @Published var members: [Participant] = []
    @Published var guests: [Participant] = []
    @Published var isLoading: Bool = false
}
