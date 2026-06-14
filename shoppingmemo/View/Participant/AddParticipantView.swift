//
//  AddParticipantView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/14.
//

import SwiftUI

struct AddParticipantView: View {
    var body: some View {
        GeometryReader { geometry in
            List {
                Section {
                    AddParticipantViewCell(itemType: .userId)
                    AddParticipantViewCell(itemType: .userName)
                    AddParticipantViewCell(itemType: .email)
                } header: {
                    Text("ユーザ情報")
                }
            }
            VStack {
                Button {
                    
                } label: {
                    Text("追加")
                }
                .frame(width: geometry.size.width * 0.6, height: 40)
                .foregroundStyle(.primary)
                .background(Color.accent)
                .contentShape(Rectangle())
                .clipShape(RoundedRectangle(cornerRadius: 20))
                Button {
                    NavigationRepository.removeViews(dest: .participant)
                } label: {
                    Text("キャンセル")
                }
                .frame(width: geometry.size.width * 0.6, height: 30)
                .foregroundStyle(.primary)
                .contentShape(Rectangle())
            }
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height * 4 / 5
            )
        }
        .navigationTitle("ユーザを追加")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    AddParticipantView()
}
