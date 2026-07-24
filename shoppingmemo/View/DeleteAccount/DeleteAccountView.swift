//
//  DeleteAccountView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/23.
//

import SwiftUI

struct DeleteAccountView: View {
    @EnvironmentObject private var pathDataStore: PathDataStore
    @State private var isEmpty: Bool = false
    @State private var deleteAccountAlertIsPresented: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            BoolSwitchView(isEmpty: isEmpty) {
                List {
                    Section {
                        DeleteAccountViewCell(itemType: .userId)
                        DeleteAccountViewCell(itemType: .userName)
                        DeleteAccountViewCell(itemType: .email)
                    } header: {
                        Text("DeleteAccountView.List.Section.header")
                    }
                }
                Button(role: .destructive) {
                    deleteAccountAlertIsPresented = true
                } label: {
                    Text("DeleteAccountView.deleteButton")
                        .frame(width: geometry.size.width * 0.6, height: 40)
                }
                .foregroundStyle(.red)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * 4 / 5
                )
            } emptyContent: {
                Text("DeleteAccountView.emptyContent.Text")
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
            }
        }
        .alert("DeleteAccountView.Alert.title", isPresented: $deleteAccountAlertIsPresented) {
            deleteAccountAlertAction()
        } message: {
            Text("DeleteAccountView.Alert.message")
        }
        .navigationTitle("DeleteAccountView.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            reauthenticate()
        }
    }
    @ViewBuilder
    func deleteAccountAlertAction() -> some View {
        CancelButton()
        DeleteButton {
            AuthRepository.deleteAccount {
                pathDataStore.navigationPath.removeAll()
            } failure: {
                reauthenticate()
            }
        }
    }
    func reauthenticate() {
        switch AuthRepository.getProvider() {
        case .google:
            Google.reauthenticate()
        case .apple:
            Apple.reauthenticate()
        case .unknown:
            break
        }
    }
}

#Preview {
    DeleteAccountView()
}
