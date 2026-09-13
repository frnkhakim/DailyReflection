import SwiftUI
import SwiftData

struct MonthGridView: View {
    @Query(sort: \Reflection.date, order: .reverse)
    private var reflections: [Reflection]

    // Which month is on screen. Starts on this one.
    @State private var month = Date.now.startOfMonth

    // Seven equal columns — one per weekday.
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    /// Day (at midnight) → that day's entry. Built once per redraw so each
    /// cell is an instant lookup instead of a search through every record.
    private var entriesByDay: [Date: Reflection] {
        Dictionary(
            reflections.map { ($0.date.startOfDay, $0) },
            // One entry per day is the rule, but this initialiser insists we
            // say what to do if that's ever broken. Keep the newest.
            uniquingKeysWith: { first, _ in first }
        )
    }

    /// The actual date for a given day number in the visible month.
    private func date(forDay day: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: day - 1, to: month) ?? month
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            grid
            Spacer()
        }
        .padding()
        .navigationTitle("Calendar")
    }

    /// Month name with arrows either side.
    private var header: some View {
        HStack {
            Button { shiftMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.headline)

            Spacer()

            Button { shiftMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    /// Weekday initials, rotated so they match the user's first day of week.
    /// These symbol lists live on DateFormatter, not on Calendar.
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.veryShortStandaloneWeekdaySymbols ?? []
        guard symbols.count == 7 else { return [] }

        // Index 0 is Sunday. Rotate so index 0 is the user's first weekday.
        let shift = Calendar.current.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 8) {

            // Row 1: the weekday letters. Tuesday and Thursday are both "T",
            // so identify by position instead of by the text itself.
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { item in
                Text(item.element)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Empty squares so the 1st lands in the right column.
            ForEach(Array(0 ..< month.leadingBlanks), id: \.self) { _ in
                Color.clear.frame(height: 40)
            }

            // The days themselves.
            ForEach(Array(1 ... month.numberOfDaysInMonth), id: \.self) { day in
                cell(forDay: day)
            }
        }
    }

    /// One day square — tappable only if that day has an entry.
    /// @ViewBuilder lets this return two different view types from the branches.
    @ViewBuilder
    private func cell(forDay day: Int) -> some View {
        let cellDate = date(forDay: day)
        let entry = entriesByDay[cellDate.startOfDay]

        let dayCell = DayCell(
            day: day,
            isToday: Calendar.current.isDateInToday(cellDate),
            hasEntry: entry != nil
        )

        if let entry {
            NavigationLink {
                ReflectionDetailView(reflection: entry)
            } label: {
                dayCell
            }
            .buttonStyle(.plain)   // stop SwiftUI tinting it blue
        } else {
            dayCell
        }
    }

    /// Moves the visible month. Calendar handles year rollover for us.
    private func shiftMonth(by value: Int) {
        guard let moved = Calendar.current.date(byAdding: .month, value: value, to: month)
        else { return }
        month = moved
    }
}
