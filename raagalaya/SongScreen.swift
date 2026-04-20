import SwiftUI

// Converted from: lib/SongScreen.dart

struct SongScreen: View {
  @ObservedObject var state: AppState

  var body: some View {
    ZStack {
      AppTheme.pageGradient.ignoresSafeArea()

      if state.sortedRaagEntries.isEmpty {
        ContentUnavailableView("No Songs Found", systemImage: "magnifyingglass", description: Text("Search by song title, film, or raag."))
          .padding()
      } else {
        ScrollView {
          VStack(alignment: .leading, spacing: 14) {
            introCard
              .sectionCardStyle()

            ForEach(state.sortedRaagEntries, id: \.key) { entry in
              ExpandableListViewSong(title: entry.key, items: entry.items)
                .sectionCardStyle()
            }
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 10)
        }
      }
    }
    .navigationTitle("Song Notebook")
    .searchable(text: $state.songFilter, prompt: "Search by song, film, or raag")
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarBackground(AppTheme.backgroundTop.opacity(0.65), for: .navigationBar)
  }

  private var introCard: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Songs by Raag")
        .font(.title3.weight(.bold))
      Text("\(state.songList.count) songs grouped to connect listening with raag study.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }
}
