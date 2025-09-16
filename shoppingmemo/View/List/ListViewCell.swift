//
//  ListViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/11.
//

import SwiftUI

struct ListViewCell: View {
    @ObservedObject var listDataStore: ListDataStore
    @ObservedObject var pathDataStore: PathDataStore
    @State var list: CustomList
    
    var body: some View {
        VStack {
            Text(list.listName)
                .font(.system(size: 25))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .draggable(list.id.uuidString)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            pathDataStore.navigationPath.append(.memos)
        }
    }
}

#Preview {
    ListViewCell(listDataStore: ListDataStore.shared, pathDataStore: PathDataStore.shared, list: CustomList())
}
