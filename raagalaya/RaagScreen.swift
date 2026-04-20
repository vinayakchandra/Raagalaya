import SwiftUI

// Converted from: lib/RaagScreen.dart

struct RaagScreen: View {
  @ObservedObject var state: AppState

  var body: some View {
    ZStack {
      AppTheme.pageGradient.ignoresSafeArea()

      if state.sortedThaathEntries.isEmpty {
        ContentUnavailableView("No Raags Found", systemImage: "magnifyingglass", description: Text("Try a different search term."))
          .padding()
      } else {
        ScrollView {
          VStack(alignment: .leading, spacing: 14) {
            introCard
              .sectionCardStyle()

            ForEach(state.sortedThaathEntries, id: \.key) { entry in
              ExpandableListViewRaag(title: entry.key, items: entry.items)
                .sectionCardStyle()
            }
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 10)
        }
      }
    }
    .navigationTitle("Raag Library")
    .searchable(text: $state.raagFilter, prompt: "Search by raag, thaat, or time")
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarBackground(AppTheme.backgroundTop.opacity(0.65), for: .navigationBar)
  }

  private var introCard: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Explore by Thaat")
        .font(.title3.weight(.bold))
      Text("\(state.raagList.count) raags organized for quick practice and reference.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }
}
