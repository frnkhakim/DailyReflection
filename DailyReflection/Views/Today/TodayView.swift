//
//  TodayView.swift
//  DailyReflection
//

import SwiftUI
import SwiftData
import OSLog

struct TodayView: View {

    // The write handle — insert, delete, save.
    @Environment(\.modelContext) private var context

    // Every reflection, newest first.
    @Query(sort: \Reflection.date, order: .reverse)
    private var reflections: [Reflection]

    /// Today's record, or nil if today hasn't been written yet.
    private var todaysEntry: Reflection? {
        let start = Date.now.startOfDay
        let end = Date.now.endOfDay
        return reflections.first { $0.date >= start && $0.date < end }
    }

    /// Consecutive days written, counting back from today.
    private var streak: Int {
        StreakCalculator.currentStreak(from: reflections.map(\.date))
    }

    @State private var wentWell = ""
    @State private var wasHard = ""
    @State private var tomorrow = ""

    // nil = keyboard dismissed. One shared value across all three cards,
    // which is what makes "only one box focused at a time" automatic.
    @FocusState private var focused: PromptField?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                PromptCard(title: "What went well today?",
                           placeholder: "One thing, however small…",
                           text: $wentWell,
                           field: .wentWell,
                           focus: $focused)

                PromptCard(title: "What was hard?",
                           placeholder: "Name it plainly.",
                           text: $wasHard,
                           field: .wasHard,
                           focus: $focused)

                PromptCard(title: "One thing for tomorrow",
                           placeholder: "Something you can actually do.",
                           text: $tomorrow,
                           field: .tomorrow,
                           focus: $focused)
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
        // A tinted page behind white cards gives the layout depth.
        .background(Color(.systemGroupedBackground))
        // Swiping down dismisses the keyboard, so the last box is reachable.
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    HistoryView()
                } label: {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            }

            // .keyboard places this bar directly above the keyboard.
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(focused == .tomorrow ? "Done" : "Next") {
                    advanceFocus()
                }
            }
        }
        // Runs once when the screen appears — before the user sees it.
        .onAppear { loadToday() }

        // Focus moved — including to nil when the keyboard dismisses.
        .onChange(of: focused) { _, _ in save() }

        // Backstop: leaving the screen without touching focus.
        .onDisappear { save() }
    }

    // MARK: - Header

    /// Weekday, date, and two status chips.
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Date.now.formatted(.dateTime.weekday(.wide)))
                .font(.largeTitle.bold())

            Text(Date.now.formatted(.dateTime.day().month(.wide).year()))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if streak > 0 {
                    chip("\(streak) day streak", icon: "flame.fill", tint: .orange)
                }

                if todaysEntry == nil {
                    chip("Not saved", icon: "circle.dashed", tint: .secondary)
                } else {
                    chip("Saved", icon: "checkmark.circle.fill", tint: .green)
                }
            }
        }
        .padding(.bottom, 2)
    }

    /// A small tinted capsule. Colour AND an icon, so it reads without colour.
    private func chip(_ text: String, icon: String, tint: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.footnote.weight(.medium))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.12), in: Capsule())
    }

    // MARK: - Actions

    /// Moves the keyboard to the next prompt, or dismisses it after the last.
    private func advanceFocus() {
        switch focused {
        case .wentWell: focused = .wasHard
        case .wasHard:  focused = .tomorrow
        default:        focused = nil   // nil dismisses the keyboard
        }
    }

    /// Fills the boxes with today's saved answers, if today has an entry.
    private func loadToday() {
        guard let entry = todaysEntry else { return }
        wentWell = entry.wentWell
        wasHard  = entry.wasHard
        tomorrow = entry.tomorrow
    }

    /// Writes the boxes to the database. Creates today's entry only if
    /// there's actually something written — an empty record would inflate
    /// the streak in Lesson 8.
    private func save() {
        let hasContent = (wentWell + wasHard + tomorrow)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty == false

        if let entry = todaysEntry {
            // Assigning to a @Model property saves it. No save() call needed.
            entry.wentWell = wentWell
            entry.wasHard  = wasHard
            entry.tomorrow = tomorrow
            // Log THAT it saved, never WHAT was written — this is a journal.
            Logger.data.info("Updated today's reflection")
        } else if hasContent {
            context.insert(
                Reflection(wentWell: wentWell, wasHard: wasHard, tomorrow: tomorrow)
            )
            Logger.data.info("Created reflection for today")
        }
    }
}

#Preview {
    NavigationStack { TodayView() }
        .modelContainer(for: Reflection.self, inMemory: true)
}
