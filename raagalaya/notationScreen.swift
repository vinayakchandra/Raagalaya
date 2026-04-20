import SwiftUI
import WebKit

// Converted from: lib/notationScreen.dart

struct NotationScreen: View {
  let fileName: String
  let tabName: String

  var body: some View {
    WebView(html: NotationFileReader.loadAsset(fileName: fileName, tabName: tabName))
      .navigationTitle(displayName)
      .navigationBarTitleDisplayMode(.inline)
  }

  private var displayName: String {
    fileName
      .replacingOccurrences(of: ".txt", with: "")
      .replacingOccurrences(of: ".html", with: "")
      .replacingOccurrences(of: "-", with: " ")
      .capitalized
  }
}

struct WebView: UIViewRepresentable {
  let html: String

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView(frame: .zero)
    webView.isOpaque = false
    webView.backgroundColor = .clear
    webView.scrollView.backgroundColor = .clear
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
    uiView.loadHTMLString(html, baseURL: nil)
  }
}
