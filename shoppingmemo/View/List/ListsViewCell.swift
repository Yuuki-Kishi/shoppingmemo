//
//  ListViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/11.
//

import SwiftUI

struct ListsViewCell: View {
    @EnvironmentObject private var listDataStore: ListDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    private let list: CustomList
    
    init(list: CustomList) {
        self.list = list
    }
    
    var body: some View {
        HStack {
            Text(list.listName)
                .font(.system(size: 25))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            Image(systemName: "chevron.forward")
                .foregroundStyle(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            listDataStore.selectedListId = list.listId
            pathDataStore.navigationPath.append(.memos)
        }
    }
}

#Preview {
    ListsViewCell(list: CustomList())
}
