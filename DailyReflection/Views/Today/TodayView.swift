//
//  TodayView.swift
//  DailyReflection
//
//  Created by Frank Hakim on 2026/08/27.
//

import SwiftUI
import SwiftData

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

    @State private var wentWell = ""
    @State private var wasHard = ""
    @State private var tomorrow = ""

    // nil = keyboard dismissed. One shared value across all three cards,
    // which is what makes "only one box focused at a time" automatic.
    @FocusState private var focused: PromptField?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Date on the left, save status on the right. Removing the
                // Save button means we owe the user a signal instead.
                HStack {
                    Text(Date.now.formatted(date: .complete, time: .omitted))

                    Spacer()

                    if todaysEntry == nil {
                        Text("Not saved")
                            .foregroundStyle(.secondary)
                    } else {
                        Label("Saved", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                PromptCard(title: "What went well today?",
                           placeholder: "One thing, however small…",
                           text: $wentWell,        // $ makes the binding
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
            .padding()
        }
        .navigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    HistoryView()
                } label: {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            }
            
            // .keyboard places this bar directly above the keyboard.
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()   // pushes the button to the right
                Button(focused == .tomorrow ? "Done" : "Next") {
                    advanceFocus()
                }
            }
        }
        // Runs once when the screen appears — before the user sees it.
        .onAppear { loadToday() }

        // Focus moved — including to nil when the keyboard dismisses.
        // The user finished a thought, so persist it.
        .onChange(of: focused) { _, _ in save() }

        // Backstop: leaving the screen without touching focus.
        .onDisappear { save() }
    }

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
        } else if hasContent {
            context.insert(
                Reflection(wentWell: wentWell, wasHard: wasHard, tomorrow: tomorrow)
            )
        }
    }
}

#Preview {
    NavigationStack { TodayView() }
        .modelContainer(for: Reflection.self, inMemory: true)
}
