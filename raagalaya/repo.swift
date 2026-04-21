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

struct SamayBucket: Identifiable {
  let slot: RaagTimeSlot
  let raags: [RaagPojo]

  var id: String { slot.rawValue }
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

  var samayBuckets: [SamayBucket] {
    RaagTimeSlot.allCases.map { slot in
      let matches = raagList
        .filter { $0.time.localizedCaseInsensitiveContains(slot.rawValue) }
        .sorted { $0.name < $1.name }
      return SamayBucket(slot: slot, raags: Array(matches.prefix(6)))
    }
  }

  func displayTimeLabel(for raag: RaagPojo) -> String {
    let key = raag.time.lowercased()
    if key.contains(RaagTimeSlot.day1.rawValue) { return "Dawn (Pratah Sandhi)" }
    if key.contains(RaagTimeSlot.day2.rawValue) { return "Morning (Poorvang focus)" }
    if key.contains(RaagTimeSlot.day3.rawValue) { return "Afternoon (Madhya day)" }
    if key.contains(RaagTimeSlot.night1.rawValue) { return "Evening (Sandhya)" }
    if key.contains(RaagTimeSlot.night2.rawValue) { return "Night (Uttarang focus)" }
    if key.contains(RaagTimeSlot.night3.rawValue) { return "Late Night (Gambhir mood)" }
    if key.contains(RaagTimeSlot.night4.rawValue) { return "Pre-Dawn (Transition)" }
    return "Flexible performance window"
  }

  func rasaProfile(for raag: RaagPojo) -> String {
    let key = raag.time.lowercased()
    if key.contains("day-1") || key.contains("day-2") { return "Bhakti and Prashant rasa (serene devotion)." }
    if key.contains("day-3") { return "Madhur and contemplative rasa (calm introspection)." }
    if key.contains("night-1") { return "Shringar and romantic evening color." }
    if key.contains("night-2") { return "Gambhir and lyrical emotional depth." }
    if key.contains("night-3") || key.contains("night-4") { return "Vairagya and meditative stillness." }
    return "Balanced emotional color with room for interpretation."
  }

  func movementGuidance(for raag: RaagPojo) -> String {
    let aroh = cleaned(raag.tonal1)
    let avroh = cleaned(raag.tonal2)
    return "Aroh: \(aroh) • Avroh: \(avroh). Emphasize smooth meend between key swaras."
  }

  func noteHierarchySummary(for raag: RaagPojo) -> String {
    let vadi = cleaned(raag.sonant)
    let samvadi = cleaned(raag.consonant)
    return "Vadi: \(vadi) • Samvadi: \(samvadi). Land and rest on these swaras during vistaar."
  }

  func voiceCultureTip(for raag: RaagPojo) -> String {
    let key = raag.time.lowercased()
    if key.contains("day") {
      return "Use open-throat aakar practice with medium laya for clear intonation."
    }
    return "Prioritize andolan, kan-swar touch, and sustained breath for depth."
  }

  func relatedRaags(for raag: RaagPojo, limit: Int = 8) -> [RaagPojo] {
    let thaat = raag.scale.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !thaat.isEmpty else { return [] }
    return raagList
      .filter { $0.fileName != raag.fileName && $0.scale.compare(thaat, options: .caseInsensitive) == .orderedSame }
      .sorted { $0.name < $1.name }
      .prefix(limit)
      .map { $0 }
  }

  func raag(forFileName fileName: String) -> RaagPojo? {
    raagList.first { $0.fileName == fileName }
  }

  func jaatiSummary(for raag: RaagPojo) -> String {
    let aroh = cleaned(raag.tonal1)
    let avroh = cleaned(raag.tonal2)
    return "\(aroh) — \(avroh)"
  }

  func poorvangUttarangHint(for raag: RaagPojo) -> String {
    let key = raag.time.lowercased()
    if key.contains("day-1") || key.contains("day-2") {
      return "Often rendered with stronger Poorvang (Sa to Ma) emphasis."
    }
    if key.contains("night-2") || key.contains("night-3") || key.contains("night-4") {
      return "Often rendered with stronger Uttarang (Pa to Sa') emphasis."
    }
    return "Use balanced Poorvang-Uttarang treatment based on bandish and gharana."
  }

  func comparisonGuidance(first: RaagPojo, second: RaagPojo) -> [String] {
    var tips: [String] = []

    if first.scale.compare(second.scale, options: .caseInsensitive) == .orderedSame {
      tips.append("Both belong to \(cleaned(first.scale)) thaat. Focus on pakad/chalan to avoid confusion.")
    } else {
      tips.append("Different thaats: \(cleaned(first.scale)) vs \(cleaned(second.scale)). Prioritize swara-color contrast.")
    }

    if cleaned(first.sonant) == cleaned(second.sonant) && cleaned(first.sonant) != "Not specified" {
      tips.append("Shared vadi \(cleaned(first.sonant)); contrast via movement and nyas points.")
    } else {
      tips.append("Different vadi-samvadi centers; land on each raag's own resting swaras.")
    }

    if cleaned(first.time) == cleaned(second.time) {
      tips.append("Same samay slot; differentiate through andolan, kan-swar, and phrase architecture.")
    } else {
      tips.append("Different samay windows suggest different emotional pacing and tonal gravity.")
    }

    return tips
  }

  func cleanedForUI(_ value: String) -> String {
    cleaned(value)
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

  private func cleaned(_ value: String) -> String {
    let text = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return text.isEmpty ? "Not specified" : text
  }
}

extension RaagTimeSlot: CaseIterable {}
