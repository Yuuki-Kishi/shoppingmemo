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
        
    var body: some View {
        List {
            ImageInfoViewCell(memoDataStore: memoDataStore, imageDataStore: imageDataStore, cellContent: .memoName)
            ImageInfoViewCell(memoDataStore: memoDataStore, imageDataStore: imageDataStore, cellContent: .userName)
            ImageInfoViewCell(memoDataStore: memoDataStore, imageDataStore: imageDataStore, cellContent: .imageSize)
            ImageInfoViewCell(memoDataStore: memoDataStore, imageDataStore: imageDataStore, cellContent: .uploadTime)
        }
    }
    
}

#Preview {
    ImageInfoView(memoDataStore: .shared, imageDataStore: .shared)
}
