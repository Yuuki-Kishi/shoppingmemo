//
//  ImageInfoView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/12.
//

import SwiftUI

struct ImageInfoView: View {
    @ObservedObject var memoDataStore: MemoDataStore
    @ObservedObject var imageDataStore: ImageDataStore
    
    @State private var userName: String = "取得中..."
    
    var body: some View {
        List {
            HStack {
                Text("添付元メモ")
                Text(memoName())
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.gray)
            }
            HStack {
                Text("登録ユーザー")
                Text(userName)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.gray)
            }
            HStack {
                Text("サイズ")
                Text(imageSize())
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.gray)
            }
            HStack {
                Text("登録日時")
                Text(uploadTime())
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.gray)
            }
        }
        .onAppear() {
            Task { await getUserName() }
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
    func getUserName() async {
        if let userId = imageDataStore.selectedMemoImage?.uploadUserId {
            if userId == "unknownUserId" {
                self.userName = "不明なユーザー"
                return
            }
            if let userName = await UserRepository.getUserData(userId: userId)?.userName {
                self.userName = userName
                return
            }
        }
        self.userName = "不明なユーザー"
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
    ImageInfoView(memoDataStore: .shared, imageDataStore: .shared)
}
