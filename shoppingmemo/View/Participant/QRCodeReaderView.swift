//
//  QRCodeReaderView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/06/15.
//

import SwiftUI
import VisionKit

struct QRCodeReaderView: View {
    @EnvironmentObject private var participantDataStore: ParticipantDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    
    var body: some View {
        ZStack {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                QRCodeReader { data in
                    if let userId = data.payloadStringValue {
                        participantDataStore.addUserId = userId
                        pathDataStore.navigationPath.append(.addParicipant)
                    }
                }
            } else {
                Text("カメラが使えません")
            }
        }
        .navigationTitle("QRコードリーダー")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    QRCodeReaderView()
}
