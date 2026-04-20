import SwiftUI

struct SongScreen: View {
  @ObservedObject var state: AppState
  @State private var selectedGroup = "All"
  @State private var spotlightMode: SongSpotlightMode = .all
  @Namespace private var tileAnimation

  var body: some View {
    ZStack {
      AppTheme.pageGradient.ignoresSafeArea()
      AppDecorativeBackground()

      ScrollView {
        VStack(alignment: .leading, spacing: 14) {
          headerCard
            .sectionCardStyle()

          spotlightPicker
            .sectionCardStyle()

          groupChips

          LazyVGrid(columns: [GridItem(.adaptive(minimum: 165), spacing: 12)], spacing: 12) {
            ForEach(filteredEntries, id: \.key) { entry in
              NavigationLink(destination: SongGroupDetailView(groupTitle: entry.key, items: entry.items)) {
                SongGroupTile(
                  title: entry.key,
                  count: entry.items.count,
                  subtitle: entry.items.first?.name ?? "",
                  isPinned: state.isPinnedSongGroup(entry.key)
                )
                .matchedGeometryEffect(id: "song-group-\(entry.key)", in: tileAnimation)
              }
              .buttonStyle(.plain)
              .contextMenu {
                Button(state.isPinnedSongGroup(entry.key) ? "Unpin Group" : "Pin Group") {
                  state.togglePinnedSongGroup(entry.key)
                }
              }
            }
          }
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: filteredEntries.count)
      }
    }
    .navigationTitle("Song Notebook")
    .searchable(text: $state.songFilter, prompt: "Search song, film, or raag")
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarBackground(AppTheme.backgroundTop.opacity(0.65), for: .navigationBar)
    .onChange(of: state.songFilter) { _, _ in selectedGroup = "All" }
  }

  private var headerCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Songs by Raag")
        .font(.system(.title2, design: .serif).weight(.bold))
      Text("\(state.songList.count) compositions to connect listening with classical structure.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      HStack(spacing: 8) {
        statPill("Favorites", "\(state.favoriteSongs.count)", icon: "star.fill")
        statPill("Pinned", "\(state.pinnedSongGroups.count)", icon: "pin.fill")
      }
    }
  }

  private var spotlightPicker: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Spotlight")
        .font(.subheadline.weight(.semibold))
      Picker("Spotlight", selection: $spotlightMode) {
        ForEach(SongSpotlightMode.allCases, id: \.self) { mode in
          Text(mode.title).tag(mode)
        }
      }
      .pickerStyle(.segmented)
    }
  }

  private var groupChips: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(groupTitles, id: \.self) { title in
          Button {
            selectedGroup = title
          } label: {
            Text(title)
              .font(.caption.weight(.semibold))
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(selectedGroup == title ? AppTheme.accent.opacity(0.2) : AppTheme.cardFill, in: Capsule())
              .overlay(
                Capsule()
                  .stroke(selectedGroup == title ? AppTheme.accent : AppTheme.border, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 2)
    }
  }

  private var filteredEntries: [(key: String, items: [SongPojo])] {
    let base = availableEntries
    guard selectedGroup != "All" else { return base }
    return base.filter { $0.key == selectedGroup }
  }

  private var availableEntries: [(key: String, items: [SongPojo])] {
    switch spotlightMode {
    case .all:
      return state.sortedRaagEntries
    case .favorites:
      let grouped = Dictionary(grouping: state.favoriteSongs, by: { $0.raag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unspecified" : $0.raag.capitalized })
      return grouped.map { ($0.key, $0.value.sorted { $0.name < $1.name }) }
        .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
    case .pinned:
      return state.sortedRaagEntries.filter { state.isPinnedSongGroup($0.key) }
    }
  }

  private var groupTitles: [String] {
    ["All"] + availableEntries.map(\.key)
  }

  private func statPill(_ label: String, _ value: String, icon: String) -> some View {
    Label("\(label): \(value)", systemImage: icon)
      .font(.caption.weight(.semibold))
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .foregroundStyle(AppTheme.accent)
      .background(AppTheme.accent.opacity(0.14), in: Capsule())
  }
}

private struct SongGroupTile: View {
  let title: String
  let count: Int
  let subtitle: String
  let isPinned: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 7) {
      HStack {
        Text(title)
          .font(.headline)
          .lineLimit(1)
        Spacer()
        if isPinned {
          Image(systemName: "pin.fill")
            .font(.caption)
            .foregroundStyle(AppTheme.accent)
        }
      }
      Text("\(count) songs")
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(subtitle)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
    .padding(12)
    .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(AppTheme.border, lineWidth: 1)
    )
  }
}

private enum SongSpotlightMode: CaseIterable {
  case all
  case favorites
  case pinned

  var title: String {
    switch self {
    case .all: return "All"
    case .favorites: return "Favorites"
    case .pinned: return "Pinned"
    }
  }
}
