import Foundation
import SwiftUI
import Combine

// Converted from: lib/repo.dart

final class AppState: ObservableObject {
  @Published var raagList: [RaagPojo] = []
  @Published var songList: [SongPojo] = []
  @Published var raagFilter = "" {
    didSet { updateGroupedData() }
  }
  @Published var songFilter = "" {
    didSet { updateGroupedData() }
  }

  @Published private(set) var thaathMap: [String: [RaagPojo]] = [:]
  @Published private(set) var raagMap: [String: [SongPojo]] = [:]

  private var hasLoadedData = false

  func loadData() {
    guard !hasLoadedData else { return }
    hasLoadedData = true

    DispatchQueue.global(qos: .userInitiated).async {
      let loadedRaags = DataLoader.loadRaags()
      let loadedSongs = DataLoader.loadSongs()

      DispatchQueue.main.async {
        self.raagList = loadedRaags
        self.songList = loadedSongs
        self.updateGroupedData()
      }
    }
  }

  var sortedThaathEntries: [(key: String, items: [RaagPojo])] {
    thaathMap
      .map { key, value in (key, value.sorted { $0.name < $1.name }) }
      .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
  }

  var sortedRaagEntries: [(key: String, items: [SongPojo])] {
    raagMap
      .map { key, value in (key, value.sorted { $0.name < $1.name }) }
      .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
  }

  private func updateGroupedData() {
    let raagSearch = raagFilter.trimmingCharacters(in: .whitespacesAndNewlines)
    let songSearch = songFilter.trimmingCharacters(in: .whitespacesAndNewlines)

    let filteredRaags = raagSearch.isEmpty
      ? raagList
      : raagList.filter {
          $0.name.localizedCaseInsensitiveContains(raagSearch)
          || $0.scale.localizedCaseInsensitiveContains(raagSearch)
          || $0.time.localizedCaseInsensitiveContains(raagSearch)
        }

    thaathMap = Dictionary(grouping: filteredRaags, by: { groupKey($0.scale, fallback: "Other") })

    let filteredSongs = songSearch.isEmpty
      ? songList
      : songList.filter {
          $0.name.localizedCaseInsensitiveContains(songSearch)
          || $0.film.localizedCaseInsensitiveContains(songSearch)
          || $0.raag.localizedCaseInsensitiveContains(songSearch)
        }

    raagMap = Dictionary(grouping: filteredSongs, by: { groupKey($0.raag, fallback: "Unspecified") })
  }

  private func groupKey(_ value: String, fallback: String) -> String {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return fallback }
    return trimmed.capitalized
  }
}
