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
            HStack {
                Text(lastEditTime())
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Text(lastEditUserName())
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(1)
            }
        }
    }
    func lastEditTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.string(from: list.lastUpdateTime)
    }
    func lastEditUserName() -> String {
        //MARK: Need Update
        return list.lastUpdateUserId
    }
}

#Preview {
    ListViewCell(listDataStore: ListDataStore.shared, pathDataStore: PathDataStore.shared, list: CustomList())
}
