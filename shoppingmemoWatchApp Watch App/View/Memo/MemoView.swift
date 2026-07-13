//
//  MemoView.swift
//  shoppingmemoWatchApp Watch App
//
//  Created by 岸　優樹 on 2026/07/13.
//

import SwiftUI

struct MemoView: View {
    @EnvironmentObject var memoDataStore: MemoDataStore
    @EnvironmentObject var pathDataStore: PathDataStore
    
    var body: some View {
        NavigationStack(path: $pathDataStore.navigationPath) {
            if pathDataStore.navigationPath.isEmpty {
                IconLabelView(iconString: "checkmark.square", labelText: "全て完了済")
            } else {
                List(memoDataStore.memoArray, id: \.memoId) { memo in
                    MemoViewCell(memo: memo)
                }
                .navigationTitle(memoDataStore.listName)
            }
        }
        
    }
}

#Preview {
    MemoView()
}
