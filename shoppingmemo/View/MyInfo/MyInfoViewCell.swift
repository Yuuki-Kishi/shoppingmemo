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
    @EnvironmentObject private var userDataStore: UserDataStore
    @EnvironmentObject private var myInfoDataStore: MyInfoDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    @State var itemType: ItemTypeEnum
    @State private var renameUserNameAlertIsPresent: Bool = false
    @State private var copiedUserIdAlertIsPresent: Bool = false
    
    init(itemType: ItemTypeEnum) {
        self.itemType = itemType
    }
    
    enum ItemTypeEnum {
        case name, email, userId, QR, creationDate, lastSignInDate, useDays, deleteAccount
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
            .alert("MyInfoViewCell.renameUserNameAlert.title", isPresented: $renameUserNameAlertIsPresent) {
                renameUserNameAlertActions()
            } message: {
                Text("MyInfoViewCell.renameUserNameAlert.message")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                myInfoDataStore.newUserName = userDataStore.signInUser?.userName ?? ""
                renameUserNameAlertIsPresent = true
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
            .alert("MyInfoViewCell.copiedUserIdAlert.title", isPresented: $copiedUserIdAlertIsPresent) {
                OKButton()
            } message: {
                Text("MyInfoViewCell.copiedUserIdAlert.message")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIPasteboard.general.string = userDataStore.signInUser?.userId ?? ""
                copiedUserIdAlertIsPresent = true
            }
        case .QR:
            VStack {
                Text(itemString())
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity,alignment: .leading)
                if myInfoDataStore.deleteAccountAlertIsPresented {
                    Rectangle()
                        .foregroundStyle(Color(uiColor: .secondarySystemGroupedBackground))
                        .frame(width: 300, height: 300, alignment: .center)
                        .padding(5)
                } else {
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
                Text("\(useDays())MyInfoViewCell.useDays.Text")
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        case .deleteAccount:
            HStack {
                Text(itemString())
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .contentShape(Rectangle())
            .alert("MyInfoViewCell.deleteAccountAlert.title", isPresented: $myInfoDataStore.deleteAccountAlertIsPresented) {
                OKButton {
                    pathDataStore.navigationPath.append(.deleteAccount)
                }
            } message: {
                Text("MyInfoViewCell.deleteAccountAlert.message")
            }
            .onTapGesture {
                myInfoDataStore.deleteAccountAlertIsPresented = true
            }
        }
    }
    func itemString() -> LocalizedStringKey {
        switch itemType {
        case .name:
            return "MyInfoViewCell.itemString.name"
        case .email:
            return "MyInfoViewCell.itemString.email"
        case .userId:
            return "MyInfoViewCell.itemString.userId"
        case .QR:
            return "MyInfoViewCell.itemString.QR"
        case .creationDate:
            return "MyInfoViewCell.itemString.creationDate"
        case .lastSignInDate:
            return "MyInfoViewCell.itemString.lastSignInDate"
        case .useDays:
            return "MyInfoViewCell.itemString.useDays"
        case .deleteAccount:
            return "MyInfoViewCell.itemString.deleteAccount"
        }
    }
    @ViewBuilder
    func renameUserNameAlertActions() -> some View {
        TextField("MyInfoViewCell.renameUserNameAlertActions.TextField.title", text: $myInfoDataStore.newUserName)
        CancelButton {
            myInfoDataStore.newUserName = ""
        }
        Button(role: .confirm) {
            Task { await UserRepository.updateUserName(newName: myInfoDataStore.newUserName) }
        } label: {
            Text("MyInfoViewCell.renameUserNameAlertActions.Button.title")
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
        guard let useDays = Calendar.current.dateComponents([.day], from: creationTime, to: Date()).day else { return "----"}
        return String(useDays)
    }
}

#Preview {
    MyInfoViewCell(itemType: .QR)
}
