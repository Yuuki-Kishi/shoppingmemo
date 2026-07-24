//
//  MemosView.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/13.
//

import SwiftUI

struct MemosView: View {
    @EnvironmentObject var memoDataStore: MemoDataStore
    @EnvironmentObject var pathDataStore: PathDataStore
    
    var body: some View {
        NavigationStack(path: $pathDataStore.navigationPath) {
            if memoDataStore.memoArray.isEmpty {
                IconLabelView(iconString: "checkmark.square", labelText: "WatchApp.MemosView.IconLabelView.labelText")
            } else {
                List(memoDataStore.memoArray, id: \.memoId) { memo in
                    MemosViewCell(memo: memo)
                }
                .navigationTitle(memoDataStore.listName)
            }
        }
    }
}

#Preview {
    MemosView()
}
