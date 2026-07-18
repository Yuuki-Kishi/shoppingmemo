//
//  NoticeListViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/07/18.
//

import SwiftUI

struct NoticeListViewCell: View {
    @EnvironmentObject private var noticeDataStore: NoticeDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    private let notice: Notice
    
    init(notice: Notice) {
        self.notice = notice
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(notice.noticeTitle)
                    .lineLimit(1)
                    .font(.system(size: 25))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(creationDateString())
                    .lineLimit(1)
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            Image(systemName: "chevron.forward")
                .foregroundStyle(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            noticeDataStore.selectedNoticeId = notice.noticeId
            pathDataStore.navigationPath.append(.notice)
        }
    }
    func creationDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: notice.creationDate)
    }
}

#Preview {
    NoticeListViewCell(notice: Notice())
}
