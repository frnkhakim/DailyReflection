import SwiftUI

struct ReflectionRow: View {
    let reflection: Reflection

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Fixed-width date column so every row lines up.
            VStack(spacing: 2) {
                Text(reflection.date.formatted(.dateTime.day()))
                    .font(.title3.weight(.semibold))
                Text(reflection.date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            // minWidth, not width — a fixed width truncates the day number
            // for anyone running larger text sizes.
            .frame(minWidth: 34)

            Text(summary)
                .lineLimit(2)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    /// The first prompt the user actually answered — a fallback chain.
    private var summary: String {
        [reflection.wentWell, reflection.wasHard, reflection.tomorrow]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? "No text"
    }
}
