//
//  MyInfoViewCell.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import SwiftUI
import FirebaseAuth
import CoreImage.CIFilterBuiltins

struct MyInfoViewCell: View {
    @ObservedObject var userDataStore: UserDataStore
    @ObservedObject var myInfoDataStore: MyInfoDataStore
    @State var itemType: ItemTypeEnum
    
    enum ItemTypeEnum {
        case name, email, userId, QR, creationDate, lastSignInDate, useDays
    }
    
    var body: some View {
        switch itemType {
        case .name:
            HStack {
                Text(itemString())
                    .foregroundStyle(.primary)
                Text(userDataStore.signInUser?.userName ?? "----")
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                myInfoDataStore.newUserName = userDataStore.signInUser?.userName ?? ""
                myInfoDataStore.renameUserNameAlertIsPresent = true
            }
        case .email:
            HStack {
                Text(itemString())
                    .foregroundStyle(.primary)
                Text(userDataStore.signInUser?.email ?? "----")
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        case .userId:
            HStack {
                Text(itemString())
                    .foregroundStyle(.primary)
                Text(userDataStore.signInUser?.userId ?? "----")
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIPasteboard.general.string = userDataStore.signInUser?.userId ?? ""
                myInfoDataStore.copiedUserIdAlertIsPresent = true
            }
        case .QR:
            VStack {
                Text(itemString())
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity,alignment: .leading)
                if let image = getQRImage() {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                        .padding(5)
                } else {
                    Image(systemName: "qrcode")
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                        .padding(5)
                }
            }
        case .creationDate:
            HStack {
                Text(itemString())
                    .foregroundStyle(.primary)
                Text(dateString(date: userDataStore.signInUser?.creationTime))
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        case .lastSignInDate:
            HStack {
                Text(itemString())
                    .foregroundStyle(.primary)
                Text(dateString(date: Auth.auth().currentUser?.metadata.lastSignInDate))
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        case .useDays:
            HStack {
                Text(itemString())
                    .foregroundStyle(.primary)
                Text(useDays() + "日")
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    func itemString() -> String {
        switch itemType {
        case .name:
            return "ユーザーネーム"
        case .email:
            return "メールアドレス"
        case .userId:
            return "ユーザーID"
        case .QR:
            return "マイQRコード"
        case .creationDate:
            return "アカウント作成日"
        case .lastSignInDate:
            return "最終ログイン日"
        case .useDays:
            return "利用日数"
        }
    }
    func getQRImage() -> UIImage? {
        let qrCodeGenerator = CIFilter.qrCodeGenerator()
        guard let userId = userDataStore.signInUser?.userId else { return nil }
        qrCodeGenerator.message = Data(userId.utf8)
        qrCodeGenerator.correctionLevel = "L"
        guard let outputimage = qrCodeGenerator.outputImage else { return nil }
        guard let cgImage = CIContext().createCGImage(outputimage, from: outputimage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    func dateString(date: Date?) -> String {
        guard let safeDate = date else { return "----" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: safeDate)
    }
    func useDays() -> String {
        guard let creationTime = userDataStore.signInUser?.creationTime else { return "----" }
        guard let useDays = Calendar.current.dateComponents([.day], from: creationTime, to: Date()).day else { return "---日"}
        return String(useDays)
    }
}

#Preview {
    MyInfoViewCell(userDataStore: .shared, myInfoDataStore: .shared, itemType: .QR)
}
