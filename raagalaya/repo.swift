import Foundation
import SwiftUI
import Combine

// Converted from: lib/repo.dart

struct RecentNotation: Identifiable, Codable, Hashable {
  let id: String
  let title: String
  let fileName: String
  let tabName: String
  let openedAt: Date
}

enum RaagTimeSlot: String {
  case day1 = "day-1"
  case day2 = "day-2"
  case day3 = "day-3"
  case night1 = "night-1"
  case night2 = "night-2"
  case night3 = "night-3"
  case night4 = "night-4"

  var title: String {
    switch self {
    case .day1: return "Dawn"
    case .day2: return "Morning"
    case .day3: return "Afternoon"
    case .night1: return "Evening"
    case .night2: return "Night"
    case .night3: return "Late Night"
    case .night4: return "Pre-Dawn"
    }
  }
}

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
  @Published private(set) var favoriteRaagFiles: Set<String> = []
  @Published private(set) var favoriteSongFiles: Set<String> = []
  @Published private(set) var pinnedRaagGroups: Set<String> = []
  @Published private(set) var pinnedSongGroups: Set<String> = []
  @Published private(set) var recentNotations: [RecentNotation] = []

  private var hasLoadedData = false
  private let userDefaults = UserDefaults.standard

  init() {
    loadPreferences()
  }

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
      .sorted {
        let lhsPinned = pinnedRaagGroups.contains($0.key)
        let rhsPinned = pinnedRaagGroups.contains($1.key)
        if lhsPinned != rhsPinned { return lhsPinned }
        return $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending
      }
  }

  var sortedRaagEntries: [(key: String, items: [SongPojo])] {
    raagMap
      .map { key, value in (key, value.sorted { $0.name < $1.name }) }
      .sorted {
        let lhsPinned = pinnedSongGroups.contains($0.key)
        let rhsPinned = pinnedSongGroups.contains($1.key)
        if lhsPinned != rhsPinned { return lhsPinned }
        return $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending
      }
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

  var raagOfTheDay: RaagPojo? {
    guard !raagList.isEmpty else { return nil }
    let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
    return raagList[day % raagList.count]
  }

  var currentTimeSlot: RaagTimeSlot {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 4..<8: return .day1
    case 8..<12: return .day2
    case 12..<16: return .day3
    case 16..<20: return .night1
    case 20..<24: return .night2
    case 0..<2: return .night3
    default: return .night4
    }
  }

  var timeOfDayRaags: [RaagPojo] {
    let key = currentTimeSlot.rawValue
    let matching = raagList.filter { $0.time.localizedCaseInsensitiveContains(key) }
      .sorted { $0.name < $1.name }
    if !matching.isEmpty {
      return Array(matching.prefix(18))
    }
    return Array(raagList.sorted { $0.name < $1.name }.prefix(18))
  }

  func isFavorite(raag: RaagPojo) -> Bool {
    favoriteRaagFiles.contains(raag.fileName)
  }

  func isFavorite(song: SongPojo) -> Bool {
    favoriteSongFiles.contains(song.fileName)
  }

  func toggleFavorite(raag: RaagPojo) {
    toggleMembership(&favoriteRaagFiles, value: raag.fileName)
    persistSet(favoriteRaagFiles, key: PersistKey.favoriteRaags)
  }

  func toggleFavorite(song: SongPojo) {
    toggleMembership(&favoriteSongFiles, value: song.fileName)
    persistSet(favoriteSongFiles, key: PersistKey.favoriteSongs)
  }

  func togglePinnedRaagGroup(_ title: String) {
    toggleMembership(&pinnedRaagGroups, value: title)
    persistSet(pinnedRaagGroups, key: PersistKey.pinnedRaagGroups)
  }

  func togglePinnedSongGroup(_ title: String) {
    toggleMembership(&pinnedSongGroups, value: title)
    persistSet(pinnedSongGroups, key: PersistKey.pinnedSongGroups)
  }

  func isPinnedRaagGroup(_ title: String) -> Bool {
    pinnedRaagGroups.contains(title)
  }

  func isPinnedSongGroup(_ title: String) -> Bool {
    pinnedSongGroups.contains(title)
  }

  func markOpenedNotation(title: String, fileName: String, tabName: String) {
    let key = "\(tabName)::\(fileName)"
    recentNotations.removeAll { $0.id == key }
    recentNotations.insert(
      RecentNotation(id: key, title: title, fileName: fileName, tabName: tabName, openedAt: Date()),
      at: 0
    )
    if recentNotations.count > 25 {
      recentNotations = Array(recentNotations.prefix(25))
    }
    persistRecents()
  }

  var favoriteRaags: [RaagPojo] {
    raagList.filter { favoriteRaagFiles.contains($0.fileName) }
      .sorted { $0.name < $1.name }
  }

  var favoriteSongs: [SongPojo] {
    songList.filter { favoriteSongFiles.contains($0.fileName) }
      .sorted { $0.name < $1.name }
  }

  private enum PersistKey {
    static let favoriteRaags = "favorite_raag_files"
    static let favoriteSongs = "favorite_song_files"
    static let pinnedRaagGroups = "pinned_raag_groups"
    static let pinnedSongGroups = "pinned_song_groups"
    static let recents = "recent_notations"
  }

  private func loadPreferences() {
    favoriteRaagFiles = Set(userDefaults.stringArray(forKey: PersistKey.favoriteRaags) ?? [])
    favoriteSongFiles = Set(userDefaults.stringArray(forKey: PersistKey.favoriteSongs) ?? [])
    pinnedRaagGroups = Set(userDefaults.stringArray(forKey: PersistKey.pinnedRaagGroups) ?? [])
    pinnedSongGroups = Set(userDefaults.stringArray(forKey: PersistKey.pinnedSongGroups) ?? [])

    guard let data = userDefaults.data(forKey: PersistKey.recents) else { return }
    if let decoded = try? JSONDecoder().decode([RecentNotation].self, from: data) {
      recentNotations = decoded
    }
  }

  private func persistSet(_ set: Set<String>, key: String) {
    userDefaults.set(Array(set), forKey: key)
  }

  private func persistRecents() {
    if let encoded = try? JSONEncoder().encode(recentNotations) {
      userDefaults.set(encoded, forKey: PersistKey.recents)
    }
  }

  private func toggleMembership(_ set: inout Set<String>, value: String) {
    if set.contains(value) {
      set.remove(value)
    } else {
      set.insert(value)
    }
  }
}
