//
//  PromptCard.swift
//  DailyReflection
//

import SwiftUI

/// The three writing boxes on the Today screen.
/// Hashable is required by @FocusState — it needs to compare values.
enum PromptField: Hashable {
    case wentWell, wasHard, tomorrow
}

struct PromptCard: View {
    let title: String              // the question
    let placeholder: String        // grey hint text
    @Binding var text: String      // live wire back to the parent
    let field: PromptField         // which box this is
    var focus: FocusState<PromptField?>.Binding   // shared keyboard focus

    /// True while the keyboard is in THIS box — drives the accent border.
    private var isFocused: Bool { focus.wrappedValue == field }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            ZStack(alignment: .topLeading) {
                // TextEditor has no placeholder, so draw one behind it.
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 10)
                        .padding(.leading, 9)
                }

                TextEditor(text: $text)
                    .frame(minHeight: 96)
                    .scrollContentBackground(.hidden)  // let our background show
                    .focused(focus, equals: field)     // claims focus when tapped
                    // The question is a separate Text above, so VoiceOver
                    // can't connect them. Say it explicitly.
                    .accessibilityLabel(title)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                // A quiet hairline normally; the accent colour while you type,
                // so it's obvious which box the keyboard belongs to.
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        isFocused ? Color.accentColor : Color(.separator).opacity(0.6),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .animation(.easeOut(duration: 0.15), value: isFocused)
        }
    }
}
