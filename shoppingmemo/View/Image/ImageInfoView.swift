//
//  ImageInfoView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/10/12.
//

import SwiftUI

struct ImageInfoView: View {
    var body: some View {
        List {
            Section {
                ImageInfoViewCell(cellContent: .userName)
                ImageInfoViewCell(cellContent: .imageSize)
                ImageInfoViewCell(cellContent: .uploadTime)
            } header: {
                Text("画像の情報")
            }
        }
    }
    
}

#Preview {
    ImageInfoView()
}
