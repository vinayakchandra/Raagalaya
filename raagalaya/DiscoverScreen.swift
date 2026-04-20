import SwiftUI

struct DiscoverScreen: View {
  @ObservedObject var state: AppState

  var body: some View {
    ZStack {
      AppTheme.pageGradient.ignoresSafeArea()
      AppDecorativeBackground()

      ScrollView {
        VStack(alignment: .leading, spacing: 14) {
          timeAwareCard
            .sectionCardStyle()

          raagTimeGrid
            .sectionCardStyle()

          favoritesCard
            .sectionCardStyle()

          recentsCard
            .sectionCardStyle()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
      }
    }
    .navigationTitle("Discover")
  }

  private var timeAwareCard: some View {
    VStack(alignment: .leading, spacing: 7) {
      Text("Raags For This Time")
        .font(.system(.title3, design: .serif).weight(.bold))
      Text("\(state.currentTimeSlot.title) listening window")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(AppTheme.accent)
      Text("Recommendations are based on current local time.")
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
  }

  private var raagTimeGrid: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Recommended Now")
        .font(.subheadline.weight(.semibold))

      LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 10)], spacing: 10) {
        ForEach(state.timeOfDayRaags, id: \.id) { raag in
          NavigationLink(destination: RaagDetailView(raag: raag).environmentObject(state)) {
            VStack(alignment: .leading, spacing: 5) {
              Text(raag.name.capitalized)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
              Text(raag.scale)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
              Text(raag.time)
                .font(.caption2)
                .foregroundStyle(AppTheme.accent)
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
            .padding(10)
            .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
            )
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  private var favoritesCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Favorites")
        .font(.subheadline.weight(.semibold))

      if state.favoriteRaags.isEmpty && state.favoriteSongs.isEmpty {
        Text("No favorites yet. Star raags and songs from their detail pages.")
          .font(.footnote)
          .foregroundStyle(.secondary)
      } else {
        ForEach(Array(state.favoriteRaags.prefix(4)), id: \.id) { raag in
          NavigationLink(destination: RaagDetailView(raag: raag).environmentObject(state)) {
            Label(raag.name.capitalized, systemImage: "star.fill")
              .font(.subheadline)
              .foregroundStyle(.primary)
          }
        }
        ForEach(Array(state.favoriteSongs.prefix(4)), id: \.id) { song in
          NavigationLink(destination: SongDetailView(song: song).environmentObject(state)) {
            Label(song.name, systemImage: "star.fill")
              .font(.subheadline)
              .foregroundStyle(.primary)
          }
        }
      }
    }
  }

  private var recentsCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Recently Opened")
        .font(.subheadline.weight(.semibold))

      if state.recentNotations.isEmpty {
        Text("Your recently opened notations will appear here.")
          .font(.footnote)
          .foregroundStyle(.secondary)
      } else {
        ForEach(Array(state.recentNotations.prefix(8))) { item in
          NavigationLink(destination: NotationScreen(fileName: item.fileName, tabName: item.tabName)) {
            VStack(alignment: .leading, spacing: 2) {
              Text(item.title)
                .font(.subheadline.weight(.medium))
              Text(item.openedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
        }
      }
    }
  }
}
