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
    @State private var newMemoNameText: String
    @State private var renameMemoNameAlertIsPresented: Bool = false
    
    init(memo: Memo) {
        self.memo = memo
        self.newMemoNameText = memo.memoName
    }
    
    var body: some View {
        HStack {
            Button {
                Task { await MemoRepository.updateIsChecked(memoId: memo.memoId, newIsChecked: !memo.isChecked) }
            } label: {
                Image(systemName: checkMarkImageName())
                    .font(.system(size: 20))
                    .foregroundStyle(Color.primary)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            Button {
                renameMemoNameAlertIsPresented = true
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
        .alert("メモの変更", isPresented: $renameMemoNameAlertIsPresented) {
            TextField("メモを入力", text: $newMemoNameText)
            Button(role: .cancel) {
                newMemoNameText = memo.memoName
            } label: {
                Text("キャンセル")
            }
            Button(role: .confirm) {
                Task { await MemoRepository.updateMemoName(memoId: memo.memoId, newMemoName: newMemoNameText) }
            } label: {
                Text("変更")
            }
        } message: {
            Text("変更後のメモを入力してください。")
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
