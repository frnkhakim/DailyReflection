//
//  PromptCard.swift
//  DailyReflection
//
//  Created by Frank Hakim on 2026/08/27.
//

import Foundation
import SwiftUI

enum PromptField: Hashable {
    case wentWell, wasHard, tomorrow
}

struct PromptCard: View {
    let title: String              // the question
    let placeholder: String        // grey hint text
    @Binding var text: String      // live wire back to the parent
    let field: PromptField         // which box this is
    var focus: FocusState<PromptField?>.Binding   // shared keyboard focus

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            ZStack(alignment: .topLeading) {
                // TextEditor has no placeholder, so draw one behind it.
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }

                TextEditor(text: $text)
                    .frame(minHeight: 90)
                    .scrollContentBackground(.hidden)  // let our background show
                    .focused(focus, equals: field)     // claims focus when tapped
            }
            .padding(8)
            // A system colour, not a fixed grey — it adapts to dark mode itself.
            .background(Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
