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
    @State var memo: Memo
    
    var body: some View {
        HStack {
            Button(action: {
                
            }, label: {
                Image(systemName: checkMarkImageName())
                    .font(.system(size: 25))
                    .foregroundStyle(Color.primary)
            })
            Button(action: {
                
            }, label: {
                Text(memo.memoName)
                    .lineLimit(1)
                    .font(.system(size: 25))
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            })
            Button(action: {
                
            }, label: {
                Image(systemName: imageMarkImageName())
                    .font(.system(size: 25))
                    .foregroundStyle(Color.primary)
            })
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
    MemosViewCell(roomDataStore: RoomDataStore.shared, listDataStore: ListDataStore.shared, memoDataStore: MemoDataStore.shared, memo: Memo())
}
