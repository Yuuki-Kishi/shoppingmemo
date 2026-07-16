//
//  DeleteAccountView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/23.
//

import SwiftUI

struct DeleteAccountView: View {
    @State private var isEmpty: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            BoolSwitchView(isEmpty: isEmpty) {
                List {
                    Section {
                        DeleteAccountViewCell(itemType: .userId)
                        DeleteAccountViewCell(itemType: .userName)
                        DeleteAccountViewCell(itemType: .email)
                    } header: {
                        Text("ユーザ情報")
                    }
                }
                Button(role: .destructive) {
                    #warning("アカウント削除処理")
                } label: {
                    Text("削除")
                        .frame(width: geometry.size.width * 0.6, height: 40)
                }
                .foregroundStyle(.red)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * 4 / 5
                )
            } emptyContent: {
                Text("アカウントが見つかりません")
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
            }
        }
        .navigationTitle("アカウント削除")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            reauthenticate()
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
