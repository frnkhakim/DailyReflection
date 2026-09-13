import Foundation
import UserNotifications

/// Schedules the daily reminder. A namespace, not an object.
enum NotificationService {

    /// One fixed id so scheduling again REPLACES the reminder
    /// rather than adding a second one.
    private static let reminderID = "daily-reflection-reminder"

    /// Shows the system permission dialog. Returns true if the user allowed it.
    /// iOS only ever shows this dialog once, so call it when the user has
    /// just asked for reminders — not on launch.
    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            // Nothing useful to do here — treat "couldn't ask" as "no".
            return false
        }
    }
    
    /// Books the daily reminder, replacing any existing one.
    static func scheduleDailyReminder(hour: Int, minute: Int) async {
        cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "Time to reflect"
        content.body = "Three questions. Two minutes."
        content.sound = .default

        // Only hour and minute — no day or month — so this matches
        // EVERY day at that time. One request, repeating forever.
        var parts = DateComponents()
        parts.hour = hour
        parts.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: true)
        let request = UNNotificationRequest(identifier: reminderID,
                                            content: content,
                                            trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }

    /// Removes the reminder. Safe to call even if nothing is scheduled.
    static func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [reminderID])
    }
}
