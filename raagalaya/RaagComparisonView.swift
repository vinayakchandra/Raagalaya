import SwiftUI

struct RaagComparisonView: View {
  @EnvironmentObject var state: AppState
  @State private var leftFileName = ""
  @State private var rightFileName = ""

  private var allRaags: [RaagPojo] {
    state.raagList.sorted { $0.name < $1.name }
  }

  private var leftRaag: RaagPojo? {
    state.raag(forFileName: leftFileName)
  }

  private var rightRaag: RaagPojo? {
    state.raag(forFileName: rightFileName)
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 14) {
        selectionCard
          .sectionCardStyle()

        if let leftRaag, let rightRaag {
          HStack(alignment: .top, spacing: 10) {
            raagColumn(raag: leftRaag, title: "Raag A")
            raagColumn(raag: rightRaag, title: "Raag B")
          }

          differentiationCard(first: leftRaag, second: rightRaag)
            .sectionCardStyle()
        } else {
          ContentUnavailableView("Select Two Raags", systemImage: "music.note.list", description: Text("Choose two raags above to compare theory and practice cues."))
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
        }
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
    }
    .navigationTitle("Compare Raags")
    .background(AppTheme.pageGradient.ignoresSafeArea())
    .onAppear {
      if leftFileName.isEmpty { leftFileName = allRaags.first?.fileName ?? "" }
      if rightFileName.isEmpty { rightFileName = allRaags.dropFirst().first?.fileName ?? leftFileName }
    }
  }

  private var selectionCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Comparison Selector")
        .font(.headline)

      Picker("Raag A", selection: $leftFileName) {
        ForEach(allRaags, id: \.fileName) { raag in
          Text(raag.name.capitalized).tag(raag.fileName)
        }
      }
      .pickerStyle(.menu)

      Picker("Raag B", selection: $rightFileName) {
        ForEach(allRaags, id: \.fileName) { raag in
          Text(raag.name.capitalized).tag(raag.fileName)
        }
      }
      .pickerStyle(.menu)
    }
  }

  private func raagColumn(raag: RaagPojo, title: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.caption.weight(.semibold))
        .foregroundStyle(AppTheme.accent)
      Text(raag.name.capitalized)
        .font(.headline)
      comparePill("Thaat", state.cleanedForUI(raag.scale))
      comparePill("Samay", state.displayTimeLabel(for: raag))
      comparePill("Jaati", state.jaatiSummary(for: raag))
      comparePill("Vadi-Samvadi", "\(state.cleanedForUI(raag.sonant)) • \(state.cleanedForUI(raag.consonant))")
      comparePill("Rasa", state.rasaProfile(for: raag))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(AppTheme.border, lineWidth: 1)
    )
  }

  private func comparePill(_ title: String, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.secondary)
      Text(value)
        .font(.caption)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private func differentiationCard(first: RaagPojo, second: RaagPojo) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("How To Avoid Confusion")
        .font(.headline)

      ForEach(state.comparisonGuidance(first: first, second: second), id: \.self) { tip in
        HStack(alignment: .top, spacing: 6) {
          Text("•")
          Text(tip)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
      }

      Text("Practice Cue")
        .font(.subheadline.weight(.semibold))
        .padding(.top, 4)
      Text("\(first.name.capitalized): \(state.poorvangUttarangHint(for: first))")
        .font(.caption)
        .foregroundStyle(.secondary)
      Text("\(second.name.capitalized): \(state.poorvangUttarangHint(for: second))")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }
}
