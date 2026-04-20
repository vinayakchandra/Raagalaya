import SwiftUI

struct AppDecorativeBackground: View {
  var body: some View {
    ZStack {
      Circle()
        .fill(AppTheme.accent.opacity(0.10))
        .frame(width: 220, height: 220)
        .offset(x: 130, y: -260)

      Circle()
        .fill(Color.blue.opacity(0.08))
        .frame(width: 280, height: 280)
        .offset(x: -160, y: 340)

      WaveStripes()
        .stroke(AppTheme.accent.opacity(0.07), lineWidth: 1.2)
        .rotationEffect(.degrees(-8))
        .offset(y: 90)
    }
    .allowsHitTesting(false)
  }
}

struct HeroRaagCard: View {
  @ObservedObject var state: AppState
  let openRaag: (RaagPojo) -> Void

  var body: some View {
    if let raag = state.raagOfTheDay {
      VStack(alignment: .leading, spacing: 8) {
        Text("Raag Of The Day")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)
        Text(raag.name.capitalized)
          .font(.system(.title3, design: .serif).weight(.bold))
        Text(detailText(for: raag))
          .font(.footnote)
          .foregroundStyle(.secondary)
        HStack(spacing: 8) {
          Label(timeMood(for: raag.time), systemImage: "sun.max.fill")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(AppTheme.accent)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(AppTheme.accent.opacity(0.16), in: Capsule())
          Spacer()
          Button("Open") { openRaag(raag) }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
        }
      }
      .padding(14)
      .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(AppTheme.border, lineWidth: 1)
      )
    }
  }

  private func detailText(for raag: RaagPojo) -> String {
    if raag.scale.isEmpty { return raag.time }
    if raag.time.isEmpty { return raag.scale }
    return "\(raag.scale) • \(raag.time)"
  }

  private func timeMood(for time: String) -> String {
    let key = time.lowercased()
    if key.contains("day-1") { return "Dawn Mood" }
    if key.contains("day-2") { return "Daylight Mood" }
    if key.contains("day-3") { return "Afternoon Mood" }
    if key.contains("night-1") { return "Sunset Mood" }
    if key.contains("night-2") { return "Evening Mood" }
    if key.contains("night-3") || key.contains("night-4") { return "Late Night Mood" }
    return "Timeless Mood"
  }
}

struct QuickActionDock: View {
  let favoritesAction: () -> Void
  let recentsAction: () -> Void
  let toggleViewAction: () -> Void

  var body: some View {
    HStack(spacing: 10) {
      quickButton(title: "Favorites", systemImage: "star.fill", action: favoritesAction)
      quickButton(title: "Recent", systemImage: "clock.fill", action: recentsAction)
      quickButton(title: "View", systemImage: "square.grid.2x2.fill", action: toggleViewAction)
    }
    .padding(8)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .stroke(AppTheme.border.opacity(0.8), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
  }

  private func quickButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Label(title, systemImage: systemImage)
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .background(AppTheme.cardFill, in: Capsule())
    }
    .buttonStyle(.plain)
  }
}

struct MiniAudioPalette: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Listening Reference")
        .font(.subheadline.weight(.semibold))
      HStack(spacing: 8) {
        chip("Alaap")
        chip("Bandish")
        chip("Taan")
      }
      RoundedRectangle(cornerRadius: 6, style: .continuous)
        .fill(AppTheme.accent.opacity(0.20))
        .frame(height: 6)
        .overlay(alignment: .leading) {
          RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(AppTheme.accent)
            .frame(width: 80, height: 6)
        }
    }
    .padding(12)
    .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(AppTheme.border, lineWidth: 1)
    )
  }

  private func chip(_ label: String) -> some View {
    Label(label, systemImage: "play.circle.fill")
      .font(.caption)
      .foregroundStyle(AppTheme.accent)
      .padding(.horizontal, 9)
      .padding(.vertical, 5)
      .background(AppTheme.accent.opacity(0.13), in: Capsule())
  }
}

struct WaveStripes: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let rows = 9
    let rowHeight = rect.height / CGFloat(rows)
    for row in 0..<rows {
      let y = CGFloat(row) * rowHeight + 16
      path.move(to: CGPoint(x: 0, y: y))
      for x in stride(from: 0.0, through: rect.width, by: 10.0) {
        let amplitude: CGFloat = 6
        let frequency = 0.03
        let waveY = y + sin(CGFloat(x) * frequency + CGFloat(row) * 0.7) * amplitude
        path.addLine(to: CGPoint(x: x, y: waveY))
      }
    }
    return path
  }
}

