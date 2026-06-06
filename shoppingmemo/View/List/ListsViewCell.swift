//
//  ListViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/11.
//

import SwiftUI

struct ListsViewCell: View {
    @StateObject var listDataStore: ListDataStore = .shared
    @StateObject var pathDataStore: PathDataStore = .shared
    @Binding var list: CustomList
    
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
            listDataStore.selectedList = list
            pathDataStore.navigationPath.append(.memos)
        }
    }
}

#Preview {
    ListsViewCell(list: Binding(get: { CustomList() }, set: {_ in}))
}
