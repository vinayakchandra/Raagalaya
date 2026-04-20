import SwiftUI

// Converted from: lib/main.dart
// SwiftUI app entry and tab shell.
//@main
struct RaagalayaSwiftUIApp: App {
  @StateObject private var state = AppState()

  var body: some Scene {
    WindowGroup {
      RootView(state: state)
        .onAppear { state.loadData() }
    }
  }
}
