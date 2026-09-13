import Foundation
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "DailyReflection"

    /// Saving, loading, deleting reflections.
    static let data = Logger(subsystem: subsystem, category: "data")

    /// Permission and reminder scheduling.
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
}
