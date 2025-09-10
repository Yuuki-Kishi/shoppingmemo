//
//  ListsView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/11.
//

import SwiftUI

struct ListsView: View {
    @StateObject var listDataStore = ListDataStore.shared
    @ObservedObject var roomDataStore: RoomDataStore
    @ObservedObject var pathDataStore: PathDataStore
    
    var body: some View {
        List(listDataStore.listArray) { list in
            
        }
    }
}

#Preview {
    ListsView(roomDataStore: RoomDataStore.shared, pathDataStore: PathDataStore.shared)
}
