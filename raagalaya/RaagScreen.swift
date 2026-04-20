import SwiftUI

struct RaagScreen: View {
  @ObservedObject var state: AppState
  @State private var selectedGroup = "All"
  @State private var showFavorites = false
  @State private var selectedHeroRaag: RaagPojo?
  @Namespace private var tileAnimation

  var body: some View {
    ZStack {
      AppTheme.pageGradient.ignoresSafeArea()
      AppDecorativeBackground()

      ScrollView {
        VStack(alignment: .leading, spacing: 14) {
          HeroRaagCard(state: state) { raag in
            selectedHeroRaag = raag
          }
          .sectionCardStyle()

          groupChips

          LazyVGrid(columns: [GridItem(.adaptive(minimum: 165), spacing: 12)], spacing: 12) {
            ForEach(filteredEntries, id: \.key) { entry in
              NavigationLink(destination: RaagGroupDetailView(groupTitle: entry.key, items: entry.items)) {
                RaagGroupTile(
                  title: entry.key,
                  count: entry.items.count,
                  subtitle: entry.items.first?.name.capitalized ?? "",
                  isPinned: state.isPinnedRaagGroup(entry.key)
                )
                .matchedGeometryEffect(id: "raag-group-\(entry.key)", in: tileAnimation)
              }
              .buttonStyle(.plain)
              .contextMenu {
                Button(state.isPinnedRaagGroup(entry.key) ? "Unpin Group" : "Pin Group") {
                  state.togglePinnedRaagGroup(entry.key)
                }
              }
            }
          }
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: filteredEntries.count)
      }
    }
    .navigationTitle("Raag Library")
    .searchable(text: $state.raagFilter, prompt: "Search raag, thaat, or time")
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button {
          showFavorites = true
        } label: {
          Label("Favorites", systemImage: "star.fill")
            .foregroundStyle(AppTheme.accent)
        }
      }
    }
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarBackground(AppTheme.backgroundTop.opacity(0.65), for: .navigationBar)
    .sheet(isPresented: $showFavorites) {
      FavoritesSheetView(tab: "raag")
        .environmentObject(state)
    }
    .sheet(item: $selectedHeroRaag) { raag in
      NavigationStack {
      RaagDetailView(raag: raag)
        .environmentObject(state)
      }
    }
    .onChange(of: state.raagFilter) { _, _ in selectedGroup = "All" }
  }

  private var groupChips: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(groupTitles, id: \.self) { title in
          Button {
            selectedGroup = title
          } label: {
            Text(title)
              .font(.caption.weight(.semibold))
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(selectedGroup == title ? AppTheme.accent.opacity(0.2) : AppTheme.cardFill, in: Capsule())
              .overlay(
                Capsule()
                  .stroke(selectedGroup == title ? AppTheme.accent : AppTheme.border, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 2)
    }
  }

  private var filteredEntries: [(key: String, items: [RaagPojo])] {
    let base = state.sortedThaathEntries
    guard selectedGroup != "All" else { return base }
    return base.filter { $0.key == selectedGroup }
  }

  private var groupTitles: [String] {
    ["All"] + state.sortedThaathEntries.map(\.key)
  }
}

private struct RaagGroupTile: View {
  let title: String
  let count: Int
  let subtitle: String
  let isPinned: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 7) {
      HStack {
        Text(title)
          .font(.headline)
          .lineLimit(1)
        Spacer()
        if isPinned {
          Image(systemName: "pin.fill")
            .font(.caption)
            .foregroundStyle(AppTheme.accent)
        }
      }
      Text("\(count) raags")
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(subtitle)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
    .padding(12)
    .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(AppTheme.border, lineWidth: 1)
    )
  }
}
