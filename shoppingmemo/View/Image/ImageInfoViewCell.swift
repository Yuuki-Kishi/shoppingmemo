//
//  ImageInfoViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/14.
//

import SwiftUI

struct ImageInfoViewCell: View {
    @StateObject var imageDataStore: ImageDataStore = .shared
    
    @State var cellContent: CellContentEnum
    @State var userName: String = "取得中..."
    
    enum CellContentEnum: String {
        case userName, imageSize, uploadTime
    }
    
    var body: some View {
        HStack {
            Text(keyString())
            Text(valueString())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(.gray)
        }
        .onAppear() {
            onAppear()
        }
    }
    func keyString() -> String {
        switch cellContent {
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
        case .userName:
            return userName
        case .imageSize:
            return imageSize()
        case .uploadTime:
            return uploadTime()
        }
    }
    func onAppear() {
        if cellContent == .userName {
            guard let uploadUserId = imageDataStore.attachedImage?.uploadUserId else { userName = "----"; return }
            UserRepository.observeUserName(userId: uploadUserId) { userName in
                guard let userName else { return }
                self.userName = userName
            }
        }
    }
    func imageSize() -> String{
        if let imageData = imageDataStore.attachedImage?.imageData {
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
        if let uploadTime = imageDataStore.attachedImage?.uploadTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            return formatter.string(from: uploadTime)
        }
        return "----/--/-- --:--:--"
    }
}

#Preview {
    ImageInfoViewCell(cellContent: .userName)
}
