import Foundation

// Converted from: lib/notaitonFileReader.dart

enum NotationFileReader {
  private static var cache: [String: String] = [:]

  static func loadAsset(fileName: String, tabName: String) -> String {
    let cacheKey = "\(tabName)/\(fileName)"
    if let cached = cache[cacheKey] {
      return cached
    }

    guard let raw = DataLoader.loadText(relativePath: "\(tabName)/\(fileName)") else {
      return "<html><body>Notation is preparing</body></html>"
    }
    let rendered = NotationParser.renderHTML(from: raw)
    cache[cacheKey] = rendered
    return rendered
  }
}
