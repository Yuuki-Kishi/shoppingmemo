//
//  ImageInfoViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/14.
//

import SwiftUI

struct ImageInfoViewCell: View {
    @ObservedObject var memoDataStore: MemoDataStore
    @ObservedObject var imageDataStore: ImageDataStore
    
    @State var cellContent: CellContentEnum
    
    enum CellContentEnum: String {
        case memoName, userName, imageSize, uploadTime
    }
    
    var body: some View {
        HStack {
            Text(keyString())
            Text(valueString())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(.gray)
        }
        .onAppear() {
            if cellContent == .userName { UserRepository.observeImageUploadUserName() }
        }
    }
    func keyString() -> String {
        switch cellContent {
        case .memoName:
            return "添付元メモ"
        case .userName:
            return "登録ユーザー"
        case .imageSize:
            return "サイズ"
        case .uploadTime:
            return "登録日時"
        }
    }
    func valueString() -> String {
        switch cellContent {
        case .memoName:
            return memoName()
        case .userName:
            return userName()
        case .imageSize:
            return imageSize()
        case .uploadTime:
            return uploadTime()
        }
    }
    func memoName() -> String {
        if let memoId = imageDataStore.selectedMemoImage?.memoId {
            if memoDataStore.selectedMemo?.memoId == memoId {
                return memoDataStore.selectedMemo?.memoName ?? "不明なメモ"
            }
        }
        return "不明なメモ"
    }
    func userName() -> String {
        guard let _ = imageDataStore.userNameResult else { return "取得中" }
        if let userName = imageDataStore.uploadUserName {
            return userName
        } else {
            return "不明なユーザー"
        }
    }
    func imageSize() -> String{
        if let imageData = imageDataStore.selectedMemoImage?.imageData {
            if imageData.count > 1000 * 1000 {
                return String(Double(imageData.count) / (1000 * 1000)) + "MB"
            } else if imageData.count > 1000 {
                return String(Double(imageData.count) / (1000)) + "KB"
            } else {
                return String(imageData.count) + "B"
            }
        }
        return "不明なサイズ"
    }
    func uploadTime() -> String {
        if let uploadTime = imageDataStore.selectedMemoImage?.uploadTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            return formatter.string(from: uploadTime)
        }
        return "----/--/-- --:--:--"
    }
}

#Preview {
    ImageInfoViewCell(memoDataStore: .shared, imageDataStore: .shared, cellContent: .memoName)
}
