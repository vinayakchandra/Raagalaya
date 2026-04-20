import Foundation

// Converted from: lib/model.dart

struct RaagPojo: Identifiable {
  let id = UUID()
  var name: String
  var scale: String
  var time: String
  var tonal1: String
  var tonal2: String
  var sonant: String
  var consonant: String
  var fileName: String
}

struct SongPojo: Identifiable {
  let id = UUID()
  var name: String
  var film: String
  var raag: String
  var fileName: String
}
