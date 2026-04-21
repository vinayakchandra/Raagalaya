import SwiftUI

struct DiscoverScreen: View {
  @ObservedObject var state: AppState

  var body: some View {
    ZStack {
      AppTheme.pageGradient.ignoresSafeArea()
      AppDecorativeBackground()

      ScrollView {
        VStack(alignment: .leading, spacing: 14) {
          comparisonEntryCard
            .sectionCardStyle()

          timeAwareCard
            .sectionCardStyle()

          raagTimeGrid
            .sectionCardStyle()

          samayChakraCard
            .sectionCardStyle()

          theoryCard
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

  private var comparisonEntryCard: some View {
    NavigationLink(destination: RaagComparisonView().environmentObject(state)) {
      HStack {
        VStack(alignment: .leading, spacing: 5) {
          Text("Raag Comparison Mode")
            .font(.headline)
            .foregroundStyle(.primary)
          Text("Compare two raags side-by-side and learn how to avoid confusion.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        Spacer()
        Image(systemName: "arrow.right.circle.fill")
          .font(.title3)
          .foregroundStyle(AppTheme.accent)
      }
    }
    .buttonStyle(.plain)
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

  private var samayChakraCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Samay Chakra")
        .font(.subheadline.weight(.semibold))
      ForEach(state.samayBuckets) { bucket in
        if !bucket.raags.isEmpty {
          VStack(alignment: .leading, spacing: 4) {
            Text(bucket.slot.title)
              .font(.caption.weight(.semibold))
              .foregroundStyle(AppTheme.accent)
            Text(bucket.raags.prefix(3).map { $0.name.capitalized }.joined(separator: ", "))
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      }
    }
  }

  private var theoryCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Raag Theory Quick Notes")
        .font(.subheadline.weight(.semibold))
      note("Each raag is more than a scale: it has a specific swara behavior and emotional color.")
      note("Vadi and Samvadi create the raag's center of gravity in alaap and vistaar.")
      note("Samay (time theory) aligns raag expression with natural voice and listener psychology.")
      note("Thaat helps classification, but pakad and chalan define true raag identity.")
    }
  }

  private func note(_ text: String) -> some View {
    HStack(alignment: .top, spacing: 6) {
      Text("•")
      Text(text)
    }
    .font(.caption)
    .foregroundStyle(.secondary)
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
