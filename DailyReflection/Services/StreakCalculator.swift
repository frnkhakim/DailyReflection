import Foundation

/// Counts consecutive days of reflection.
/// A caseless enum can't be instantiated — it's a namespace, not an object.
enum StreakCalculator {

    /// How many days in a row, counting back from `today`.
    /// `today` is a parameter, not Date.now, so tests can pretend it's
    /// any day they like without touching the system clock.
    static func currentStreak(from dates: [Date], today: Date = .now) -> Int {
        // Normalise to midnight so two entries on the same day collapse
        // into one, and so lookups compare cleanly.
        let days = Set(dates.map { $0.startOfDay })
        guard !days.isEmpty else { return 0 }

        let calendar = Calendar.current
        var cursor = today.startOfDay

        // Today being unwritten doesn't break anything — the user may
        // simply not have written yet. Start from yesterday instead.
        if !days.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor)
            else { return 0 }
            cursor = yesterday
        }

        var streak = 0
        while days.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor)
            else { break }
            cursor = previous
        }
        return streak
    }
}
