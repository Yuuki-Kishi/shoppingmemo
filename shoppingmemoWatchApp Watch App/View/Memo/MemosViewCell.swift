//
//  MemosViewCell.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/13.
//

import SwiftUI

struct MemosViewCell: View {
    private let memo: Memo
    
    init(memo: Memo) {
        self.memo = memo
    }
    
    var body: some View {
        HStack {
            Image(systemName: checkboxImageString())
            Text(memo.memoName)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Image(systemName: imageboxImageString())
        }
        .contentShape(Rectangle())
        .onTapGesture {
            SessionRepository.sendCheck(memoId: memo.memoId)
        }
    }
    func checkboxImageString() -> String {
        if memo.isChecked {
            return "checkmark.square"
        } else {
            return "square"
        }
    }
    func imageboxImageString() -> String {
        guard memo.imageUrl != "default" else { return "plus.viewfinder" }
        return "photo"
    }
}

#Preview {
    MemosViewCell(memo: Memo())
}
