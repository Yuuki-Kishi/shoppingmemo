//
//  NoticeListView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/18.
//

import SwiftUI

struct NoticeListView: View {
    @EnvironmentObject private var noticeDataStore: NoticeDataStore
    
    var body: some View {
        ZStack {
            BoolSwitchView(isEmpty: noticeDataStore.noticeArray.isEmpty, isLoading: noticeDataStore.isLoading) {
                List(noticeDataStore.noticeArray, id: \.noticeId) { notice in
                    NoticeListViewCell(notice: notice)
                }
                .listRowSpacing(35)
            } emptyContent: {
                Text("NoticeListsView.emptyContent.Text")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HelpButton()
            }
        }
        .navigationTitle("NoticeListsView.navigationTitle")
        .onAppear() {
            noticeDataStore.isLoading = true
            NoticeRepository.clearNotices()
            NoticeRepository.observeNotices {
                noticeDataStore.isLoading = false
            }
        }
    }
}

#Preview {
    NoticeListView()
}
