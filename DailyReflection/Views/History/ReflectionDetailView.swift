//
//  ReflectionDetailView.swift
//  DailyReflection
//

import SwiftUI
import SwiftData

struct ReflectionDetailView: View {
    // @Bindable lets us make bindings ($reflection.wentWell) straight to
    // a database object. Edits save themselves — no save() needed here.
    @Bindable var reflection: Reflection

    // Each screen owns its own focus state.
    @FocusState private var focused: PromptField?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PromptCard(title: "What went well?",
                           placeholder: "Nothing written",
                           text: $reflection.wentWell,
                           field: .wentWell,
                           focus: $focused)

                PromptCard(title: "What was hard?",
                           placeholder: "Nothing written",
                           text: $reflection.wasHard,
                           field: .wasHard,
                           focus: $focused)

                PromptCard(title: "One thing for tomorrow",
                           placeholder: "Nothing written",
                           text: $reflection.tomorrow,
                           field: .tomorrow,
                           focus: $focused)
            }
            .padding()
        }
        .navigationTitle(reflection.date.formatted(date: .abbreviated, time: .omitted))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareText)
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focused = nil }
            }
        }
    }

    /// The entry as plain text for sharing. Prompts the user left blank
    /// are skipped — an empty heading in an email looks broken.
    private var shareText: String {
        let body = [
            ("What went well", reflection.wentWell),
            ("What was hard", reflection.wasHard),
            ("One thing for tomorrow", reflection.tomorrow)
        ]
        .map { ($0.0, $0.1.trimmingCharacters(in: .whitespacesAndNewlines)) }
        .filter { !$0.1.isEmpty }
        .map { "\($0.0)\n\($0.1)" }
        .joined(separator: "\n\n")

        let heading = reflection.date.formatted(date: .complete, time: .omitted)
        return "\(heading)\n\n\(body)"
    }
}
