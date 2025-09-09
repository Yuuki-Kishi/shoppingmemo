//
//  RoomView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/09.
//

import SwiftUI

struct RoomsView: View {
    @StateObject var roomDataStore = RoomDataStore.shared
    @StateObject var pathDataStore = PathDataStore.shared
    
    var body: some View {

    }
    func destination(path: PathDataStore.path) -> some View {
        switch path {
        case .rooms:
        }
    }
}

#Preview {
    RoomsView()
}
