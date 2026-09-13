import SwiftUI

struct DayCell: View {
    let day: Int
    let isToday: Bool
    let hasEntry: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("\(day)")
                .font(.callout)
                .foregroundStyle(hasEntry ? Color.primary : Color.secondary)

            // A fixed-size dot, made invisible rather than removed —
            // that keeps every cell the same height so rows stay even.
            Circle()
                .frame(width: 5, height: 5)
                .foregroundStyle(hasEntry ? Color.accentColor : Color.clear)
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .overlay {
            if isToday {
                Circle()
                    .strokeBorder(Color.accentColor, lineWidth: 1.5)
                    .frame(width: 34, height: 34)
            }
        }
    }
}
