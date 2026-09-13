import SwiftUI

struct SettingsView: View {
    // @AppStorage is UserDefaults-backed: behaves like @State,
    // but the value is still there after the app restarts.
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 21
    @AppStorage("reminderMinute") private var reminderMinute = 0

    // Set if the user has previously refused notifications.
    @State private var showPermissionAlert = false
    
    /// DatePicker wants a Date; we store two Ints. This bridges them.
    /// A Binding is nothing more than a get closure and a set closure.
    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: reminderHour,
                                      minute: reminderMinute,
                                      second: 0,
                                      of: .now) ?? .now
            },
            set: { newValue in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = parts.hour ?? 21
                reminderMinute = parts.minute ?? 0
            }
        )
    }

    var body: some View {
        Form {
            Section {
                // Only shown when reminders are on — no point choosing a
                // time for something that isn't going to happen.
                if reminderEnabled {
                    DatePicker("Time",
                               selection: reminderTime,
                               displayedComponents: .hourAndMinute)
                }
                
                Toggle("Daily reminder", isOn: $reminderEnabled)
            } footer: {
                Text("A nudge at the same time each evening. You can turn this off at any time.")
            }
        }
        .navigationTitle("Settings")
        
        .onChange(of: reminderEnabled) { _, _ in updateSchedule() }
        .onChange(of: reminderHour) { _, _ in updateSchedule() }
        .onChange(of: reminderMinute) { _, _ in updateSchedule() }
        .alert("Notifications are off", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Not now", role: .cancel) { }
        } message: {
            Text("Turn on notifications for Daily Reflection in the Settings app to get your reminder.")
        }
    }
    
    /// Books or cancels the reminder to match the current settings.
    private func updateSchedule() {
        Task {
            guard reminderEnabled else {
                NotificationService.cancelDailyReminder()
                return
            }

            let granted = await NotificationService.requestPermission()

            guard granted else {
                // iOS won't show the dialog a second time, so the only
                // honest thing is to switch the toggle back off and say why.
                reminderEnabled = false
                showPermissionAlert = true
                return
            }

            await NotificationService.scheduleDailyReminder(hour: reminderHour,
                                                            minute: reminderMinute)
        }
    }
}
