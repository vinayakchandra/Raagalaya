import SwiftUI

// Converted from: lib/ExpandableListViewRaag.dart

struct ExpandableListViewRaag: View {
  let title: String
  let items: [RaagPojo]
  @State private var expanded = false

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Button {
        withAnimation(.easeInOut(duration: 0.2)) {
          expanded.toggle()
        }
      } label: {
        HStack(spacing: 10) {
          Text(title)
            .font(.headline.weight(.semibold))
          Text("\(items.count)")
            .font(.caption.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(AppTheme.accent.opacity(0.15), in: Capsule())
            .foregroundStyle(AppTheme.accent)
          Spacer()
          Image(systemName: expanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
            .foregroundStyle(AppTheme.accent)
            .font(.title3)
        }
      }
      .buttonStyle(.plain)

      if expanded {
        VStack(spacing: 10) {
          ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            NavigationLink(destination: NotationScreen(fileName: item.fileName, tabName: "raag")) {
              VStack(alignment: .leading, spacing: 4) {
                Text("\(index + 1). \(item.name.capitalized)")
                  .font(.subheadline.weight(.semibold))
                  .foregroundStyle(.primary)
                Text(detailText(for: item))
                  .font(.caption)
                  .foregroundStyle(.secondary)
                  .lineLimit(2)
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(10)
              .background(AppTheme.cardFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
              .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                  .stroke(AppTheme.border.opacity(0.5), lineWidth: 1)
              )
            }
            .buttonStyle(.plain)
          }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
  }

  private func detailText(for item: RaagPojo) -> String {
    if item.scale.isEmpty {
      return item.time
    }
    if item.time.isEmpty {
      return item.scale
    }
    return "\(item.scale) • \(item.time)"
  }
}
