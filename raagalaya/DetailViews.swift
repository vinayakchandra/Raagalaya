import SwiftUI

struct RaagDetailView: View {
  @EnvironmentObject var state: AppState
  let raag: RaagPojo

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 14) {
        Text(raag.name.capitalized)
          .font(.system(.largeTitle, design: .serif).weight(.bold))
          .contentTransition(.numericText())

        detailGrid
        raagEssenceCard
        pedagogyCard
        tonalCard
        relatedRaagsCard
        MiniAudioPalette()

        NavigationLink(destination: notationDestination) {
          Label("Open Notation", systemImage: "music.quarternote.3")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.accent)
        .simultaneousGesture(TapGesture().onEnded {
          state.markOpenedNotation(title: raag.name.capitalized, fileName: raag.fileName, tabName: "raag")
        })
      }
      .padding(16)
    }
    .navigationTitle("Raag Detail")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          state.toggleFavorite(raag: raag)
        } label: {
          Image(systemName: state.isFavorite(raag: raag) ? "star.fill" : "star")
            .foregroundStyle(AppTheme.accent)
        }
      }
    }
    .background(AppTheme.pageGradient.ignoresSafeArea())
  }

  private var notationDestination: some View {
    NotationScreen(fileName: raag.fileName, tabName: "raag")
  }

  private var detailGrid: some View {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
      infoCard("Thaat", raag.scale)
      infoCard("Practice Time", raag.time)
      infoCard("Tonal Pattern 1", raag.tonal1)
      infoCard("Tonal Pattern 2", raag.tonal2)
    }
  }

  private var tonalCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Core Notes")
        .font(.headline)
      HStack {
        notePill(title: "Vadi", value: raag.sonant)
        notePill(title: "Samvadi", value: raag.consonant)
      }
    }
    .padding(12)
    .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(AppTheme.border, lineWidth: 1)
    )
  }

  private var raagEssenceCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Raag Essence")
        .font(.headline)
      Text(state.displayTimeLabel(for: raag))
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(AppTheme.accent)
      Text(state.rasaProfile(for: raag))
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .padding(12)
    .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(AppTheme.border, lineWidth: 1)
    )
  }

  private var pedagogyCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Practice Guidance")
        .font(.headline)
      bullet(state.movementGuidance(for: raag))
      bullet(state.noteHierarchySummary(for: raag))
      bullet(state.voiceCultureTip(for: raag))
    }
    .padding(12)
    .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(AppTheme.border, lineWidth: 1)
    )
  }

  private var relatedRaagsCard: some View {
    let related = state.relatedRaags(for: raag)
    return VStack(alignment: .leading, spacing: 8) {
      Text("Related Raags (Same Thaat)")
        .font(.headline)
      if related.isEmpty {
        Text("No related raags found in this thaat.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      } else {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], spacing: 8) {
          ForEach(related, id: \.id) { item in
            NavigationLink(destination: RaagDetailView(raag: item).environmentObject(state)) {
              Text(item.name.capitalized)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(AppTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
    .padding(12)
    .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(AppTheme.border, lineWidth: 1)
    )
  }

  private func bullet(_ text: String) -> some View {
    HStack(alignment: .top, spacing: 6) {
      Text("•")
      Text(text)
        .fixedSize(horizontal: false, vertical: true)
    }
    .font(.subheadline)
    .foregroundStyle(.secondary)
  }

  private func infoCard(_ title: String, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
      Text(cleaned(value))
        .font(.subheadline.weight(.medium))
        .lineLimit(3)
    }
    .frame(maxWidth: .infinity, minHeight: 68, alignment: .leading)
    .padding(10)
    .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .stroke(AppTheme.border, lineWidth: 1)
    )
  }

  private func notePill(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(title)
        .font(.caption2)
        .foregroundStyle(.secondary)
      Text(cleaned(value))
        .font(.subheadline.weight(.semibold))
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 8)
    .background(AppTheme.accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
  }

  private func cleaned(_ value: String) -> String {
    let text = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return text.isEmpty ? "Not specified" : text
  }
}

struct SongDetailView: View {
  @EnvironmentObject var state: AppState
  let song: SongPojo

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 14) {
        Text(song.name)
          .font(.system(.title2, design: .serif).weight(.bold))

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
          infoCard("Film", song.film)
          infoCard("Raag", song.raag)
        }

        MiniAudioPalette()

        NavigationLink(destination: notationDestination) {
          Label("Open Song Notation", systemImage: "music.note")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.accent)
        .simultaneousGesture(TapGesture().onEnded {
          state.markOpenedNotation(title: song.name, fileName: song.fileName, tabName: "song")
        })
      }
      .padding(16)
    }
    .navigationTitle("Song Detail")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          state.toggleFavorite(song: song)
        } label: {
          Image(systemName: state.isFavorite(song: song) ? "star.fill" : "star")
            .foregroundStyle(AppTheme.accent)
        }
      }
    }
    .background(AppTheme.pageGradient.ignoresSafeArea())
  }

  private var notationDestination: some View {
    NotationScreen(fileName: song.fileName, tabName: "song")
  }

  private func infoCard(_ title: String, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
      Text(cleaned(value))
        .font(.subheadline.weight(.medium))
        .lineLimit(3)
    }
    .frame(maxWidth: .infinity, minHeight: 68, alignment: .leading)
    .padding(10)
    .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .stroke(AppTheme.border, lineWidth: 1)
    )
  }

  private func cleaned(_ value: String) -> String {
    let text = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return text.isEmpty ? "Not specified" : text
  }
}

struct FavoritesSheetView: View {
  @EnvironmentObject var state: AppState
  let tab: String
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      List {
        if tab == "raag" {
          ForEach(state.favoriteRaags, id: \.id) { raag in
            NavigationLink(destination: RaagDetailView(raag: raag)) {
              Text(raag.name.capitalized)
            }
          }
        } else {
          ForEach(state.favoriteSongs, id: \.id) { song in
            NavigationLink(destination: SongDetailView(song: song)) {
              Text(song.name)
            }
          }
        }
      }
      .navigationTitle("Favorites")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
    }
  }
}

struct RecentsSheetView: View {
  @EnvironmentObject var state: AppState
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      List(state.recentNotations) { item in
        NavigationLink(destination: NotationScreen(fileName: item.fileName, tabName: item.tabName)) {
          VStack(alignment: .leading, spacing: 2) {
            Text(item.title)
            Text(item.openedAt.formatted(date: .abbreviated, time: .shortened))
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      }
      .navigationTitle("Recently Opened")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
    }
  }
}

struct RaagGroupDetailView: View {
  @EnvironmentObject var state: AppState
  let groupTitle: String
  let items: [RaagPojo]

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 10) {
        ForEach(items.sorted { $0.name < $1.name }, id: \.id) { raag in
          NavigationLink(destination: RaagDetailView(raag: raag).environmentObject(state)) {
            HStack(spacing: 10) {
              VStack(alignment: .leading, spacing: 3) {
                Text(raag.name.capitalized)
                  .font(.subheadline.weight(.semibold))
                Text(raag.time.isEmpty ? raag.scale : "\(raag.scale) • \(raag.time)")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
              Spacer()
              Image(systemName: state.isFavorite(raag: raag) ? "star.fill" : "chevron.right.circle.fill")
                .foregroundStyle(state.isFavorite(raag: raag) ? AppTheme.accent : .secondary)
            }
            .padding(12)
            .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
            )
          }
          .buttonStyle(.plain)
        }
      }
      .padding(14)
    }
    .background(AppTheme.pageGradient.ignoresSafeArea())
    .navigationTitle(groupTitle)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(state.isPinnedRaagGroup(groupTitle) ? "Unpin" : "Pin") {
          state.togglePinnedRaagGroup(groupTitle)
        }
      }
    }
  }
}

struct SongGroupDetailView: View {
  @EnvironmentObject var state: AppState
  let groupTitle: String
  let items: [SongPojo]

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 10) {
        ForEach(items.sorted { $0.name < $1.name }, id: \.id) { song in
          NavigationLink(destination: SongDetailView(song: song).environmentObject(state)) {
            HStack(spacing: 10) {
              VStack(alignment: .leading, spacing: 3) {
                Text(song.name)
                  .font(.subheadline.weight(.semibold))
                Text(song.film.trimmingCharacters(in: .whitespacesAndNewlines))
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
              Spacer()
              Image(systemName: state.isFavorite(song: song) ? "star.fill" : "chevron.right.circle.fill")
                .foregroundStyle(state.isFavorite(song: song) ? AppTheme.accent : .secondary)
            }
            .padding(12)
            .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
            )
          }
          .buttonStyle(.plain)
        }
      }
      .padding(14)
    }
    .background(AppTheme.pageGradient.ignoresSafeArea())
    .navigationTitle(groupTitle)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(state.isPinnedSongGroup(groupTitle) ? "Unpin" : "Pin") {
          state.togglePinnedSongGroup(groupTitle)
        }
      }
    }
  }
}
