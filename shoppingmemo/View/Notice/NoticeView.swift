//
//  NoticeView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/18.
//

import SwiftUI

struct NoticeView: View {
    @EnvironmentObject private var noticeDataStore: NoticeDataStore
    
    var body: some View {
        ScrollView {
            Text(noticeContent())
                .frame(maxWidth: .infinity)
                .padding()
            Text(creationDateString())
                .lineLimit(1)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .padding()
        }
        .navigationTitle(noticeTitleString())
    }
    func noticeContent()-> String {
        guard let selectedNoticeContent = noticeDataStore.noticeArray.selected?.noticeContent else { return "----" }
        return selectedNoticeContent
    }
    func creationDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        guard let selectedNoticeCreationDate = noticeDataStore.noticeArray.selected?.creationDate else { return "----" }
        return formatter.string(from: selectedNoticeCreationDate)
    }
    func noticeTitleString() -> String {
        guard let selectedNoticeTitle = noticeDataStore.noticeArray.selected?.noticeTitle else { return "NoticeView.navigationTitle.unknownNoticeTitle" }
        return selectedNoticeTitle
    }
}

#Preview {
    NoticeView()
        .environmentObject(NoticeDataStore.shared)
}
