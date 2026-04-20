import SwiftUI
import Foundation

// Shared helpers for converted files.

struct RootView: View {
  @ObservedObject var state: AppState

  var body: some View {
    TabView {
      NavigationStack { RaagScreen(state: state) }
        .tabItem { Label("Raag", systemImage: "music.note.list") }

      NavigationStack { SongScreen(state: state) }
        .tabItem { Label("Song", systemImage: "text.book.closed") }

      NavigationStack { DiscoverScreen(state: state) }
        .tabItem { Label("Discover", systemImage: "sparkles") }
    }
    .tint(AppTheme.accent)
    .environmentObject(state)
  }
}

enum AppTheme {
  static let accent = Color(uiColor: UIColor { trait in
    trait.userInterfaceStyle == .dark
      ? UIColor(red: 0.98, green: 0.68, blue: 0.36, alpha: 1)
      : UIColor(red: 0.75, green: 0.34, blue: 0.08, alpha: 1)
  })

  static let backgroundTop = Color(uiColor: UIColor { trait in
    trait.userInterfaceStyle == .dark
      ? UIColor(red: 0.10, green: 0.11, blue: 0.14, alpha: 1)
      : UIColor(red: 0.98, green: 0.95, blue: 0.89, alpha: 1)
  })

  static let backgroundBottom = Color(uiColor: UIColor { trait in
    trait.userInterfaceStyle == .dark
      ? UIColor(red: 0.07, green: 0.08, blue: 0.11, alpha: 1)
      : UIColor(red: 0.93, green: 0.96, blue: 0.99, alpha: 1)
  })

  static let cardFill = Color(uiColor: UIColor { trait in
    trait.userInterfaceStyle == .dark
      ? UIColor.secondarySystemBackground.withAlphaComponent(0.78)
      : UIColor.systemBackground.withAlphaComponent(0.92)
  })

  static let border = Color(uiColor: UIColor { trait in
    trait.userInterfaceStyle == .dark
      ? UIColor.white.withAlphaComponent(0.15)
      : UIColor(red: 0.77, green: 0.67, blue: 0.52, alpha: 0.45)
  })

  static let pageGradient = LinearGradient(
    colors: [backgroundTop, backgroundBottom],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
}

struct SectionCard: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(AppTheme.border, lineWidth: 1)
      )
      .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 7)
  }
}

extension View {
  func sectionCardStyle() -> some View {
    modifier(SectionCard())
  }
}

enum DataLoader {
  static func loadRaags() -> [RaagPojo] {
    guard let csv = loadText(relativePath: "raag/raagList.csv") else { return [] }
    return CSVParser.parse(csv).compactMap { row in
      guard row.count >= 8 else { return nil }
      return RaagPojo(name: row[0], scale: row[1], time: row[2], tonal1: row[3], tonal2: row[4], sonant: row[5], consonant: row[6], fileName: row[7])
    }
  }

  static func loadSongs() -> [SongPojo] {
    guard let csv = loadText(relativePath: "song/songList.csv") else { return [] }
    return CSVParser.parse(csv).compactMap { row in
      guard row.count >= 4 else { return nil }
      return SongPojo(name: row[0], film: row[1], raag: row[2], fileName: row[3].trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }

  static func loadText(relativePath: String) -> String? {
    guard let root = Bundle.main.resourceURL else { return nil }
    let possible = [
      root.appendingPathComponent("assets").appendingPathComponent(relativePath),
      root.appendingPathComponent("Resources/assets").appendingPathComponent(relativePath),
    ]
    for url in possible where FileManager.default.fileExists(atPath: url.path) {
      if let text = try? String(contentsOf: url, encoding: .utf8) { return text }
    }
    return nil
  }
}

enum CSVParser {
  static func parse(_ raw: String) -> [[String]] {
    var rows: [[String]] = []
    var row: [String] = []
    var field = ""
    var inQuotes = false

    for character in raw {
      switch character {
      case "\"":
        inQuotes.toggle()
      case "," where !inQuotes:
        row.append(field.trimmingCharacters(in: .whitespacesAndNewlines))
        field = ""
      case "\n" where !inQuotes:
        row.append(field.trimmingCharacters(in: .whitespacesAndNewlines))
        if !row.isEmpty { rows.append(row) }
        row = []
        field = ""
      case "\r":
        continue
      default:
        field.append(character)
      }
    }

    if !field.isEmpty || !row.isEmpty {
      row.append(field.trimmingCharacters(in: .whitespacesAndNewlines))
      rows.append(row)
    }

    return rows
  }
}

enum NotationParser {
  static func renderHTML(from text: String) -> String {
    var rows: [String] = []
    var didRenderSection = false

    text.components(separatedBy: .newlines).forEach { line in
      let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else { return }

      if trimmed.hasSuffix(":") {
        let title = String(trimmed.dropLast())
        if didRenderSection {
          rows.append("<hr>")
        }
        rows.append("<h3>\(escapeHTML(title))</h3>")
        didRenderSection = true
      } else {
        rows.append("<pre>\(escapeHTML(trimmed))</pre>")
      }
    }

    return """
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { background: #fffdf6; color: #2f2720; font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif; padding: 18px 18px calc(120px + env(safe-area-inset-bottom)) 18px; line-height: 1.45; }
            h3 { margin: 14px 0 6px; font-size: 17px; color: #7a3e17; }
            pre { white-space: pre-wrap; font-family: 'SF Mono', Menlo, monospace; background: #fff7e6; border: 1px solid #f0d8aa; border-radius: 10px; padding: 11px 12px; margin: 7px 0; font-size: 14px; }
            hr { border: 0; border-top: 1px solid #ecd8b4; margin: 14px 0; }
            @media (prefers-color-scheme: dark) {
              body { background: #101318; color: #f4ebdb; }
              h3 { color: #f1b37f; }
              pre { background: #1b2028; border-color: #3b4658; color: #f9f7f0; }
              hr { border-top-color: #364154; }
            }
          </style>
        </head>
        <body>\(rows.joined())</body>
      </html>
      """
  }

  private static func escapeHTML(_ input: String) -> String {
    input
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;")
  }
}
