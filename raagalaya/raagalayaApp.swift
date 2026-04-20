//
//  raagalayaApp.swift
//  raagalaya
//
//  Created by admin55 on 20/04/26.
//

import SwiftUI

@main
struct raagalayaApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView(state: state)
                .onAppear {
                    state.loadData()
                }
        }
    }
}
