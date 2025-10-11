//
//  MemosViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/13.
//

import SwiftUI

struct MemosViewCell: View {
    @ObservedObject var roomDataStore: RoomDataStore
    @ObservedObject var listDataStore: ListDataStore
    @ObservedObject var memoDataStore: MemoDataStore
    @ObservedObject var pathDataStore: PathDataStore
    @Binding var memo: Memo
    
    var body: some View {
        HStack {
            Button(action: {
                print("checked")
            }, label: {
                Image(systemName: checkMarkImageName())
                    .font(.system(size: 20))
                    .foregroundStyle(Color.primary)
            })
            .buttonStyle(.plain)
            Button(action: {
                print("updateMemo")
            }, label: {
                Text(memo.memoName)
                    .lineLimit(1)
                    .font(.system(size: 25))
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            })
            .buttonStyle(.plain)
            Button(action: {
                memoDataStore.selectedMemo = memo
                pathDataStore.navigationPath.append(.image)
            }, label: {
                Image(systemName: imageMarkImageName())
                    .font(.system(size: 25))
                    .foregroundStyle(Color.primary)
            })
            .buttonStyle(.plain)
        }
    }
    func checkMarkImageName() -> String {
        if memo.isChecked {
            return "checkmark.square"
        } else {
            return "square"
        }
    }
    func imageMarkImageName() -> String {
        if memo.imageUrl == "default" || memo.imageUrl == "unknown" {
            return "plus.viewfinder"
        } else {
            return "photo"
        }
    }
}

#Preview {
    MemosViewCell(roomDataStore: .shared, listDataStore: .shared, memoDataStore: .shared, pathDataStore: .shared, memo: Binding(get: { Memo() }, set: {_ in}))
}
