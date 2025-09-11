//
//  ContentView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var userDataStore = UserDataStore.shared
    
    var body: some View {
        if userDataStore.userResult == nil {
            LoadingView()
                .onAppear() {
                    
                }
        } else {
            if userDataStore.signInUser == nil {
                SignInView()
            } else {
                RoomsView(userDataStore: userDataStore)
            }
        }
    }
}

#Preview {
    ContentView()
}
