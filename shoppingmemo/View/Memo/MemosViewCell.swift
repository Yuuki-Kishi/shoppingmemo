//
//  MemosViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/13.
//

import SwiftUI

struct MemosViewCell: View {
    @EnvironmentObject private var memoDataStore: MemoDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    private let memo: Memo
    
    init(memo: Memo) {
        self.memo = memo
    }
    
    var body: some View {
        HStack {
            Button {
                Task { await MemoRepository.updateIsChecked(memo: memo) }
            } label: {
                Image(systemName: checkMarkImageName())
                    .font(.system(size: 20))
                    .foregroundStyle(Color.primary)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            Button {
                print("updateMemo")
            } label: {
                Text(memo.memoName)
                    .lineLimit(1)
                    .font(.system(size: 25))
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            Button {
                memoDataStore.selectedMemoId = memo.memoId
                pathDataStore.navigationPath.append(.image)
            } label: {
                Image(systemName: imageMarkImageName())
                    .font(.system(size: 25))
                    .foregroundStyle(Color.primary)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
        }
    }
    func checkMarkImageName() -> String {
        memo.isChecked ? "checkmark.square" : "square"
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
    MemosViewCell(memo: Memo())
}
