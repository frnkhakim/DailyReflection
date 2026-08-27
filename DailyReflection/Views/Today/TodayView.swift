//
//  TodayView.swift
//  DailyReflection
//
//  Created by Frank Hakim on 2026/08/27.
//

import Foundation

import SwiftUI

struct TodayView: View {
    
    @State private var wentWell = ""
    @State private var wasHard = ""
    @State private var tomorrow = ""

    // nil = keyboard dismissed. One shared value across all three cards,
    // which is what makes "only one box focused at a time" automatic.
    @FocusState private var focused: PromptField?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(Date.now.formatted(date: .complete, time: .omitted))
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
            // .keyboard places this bar directly above the keyboard.
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()   // pushes the button to the right
                Button(focused == .tomorrow ? "Done" : "Next") {
                    advanceFocus()
                }
            }
        }
    }
    
    /// Moves the keyboard to the next prompt, or dismisses it after the last.
    private func advanceFocus() {
        switch focused {
        case .wentWell: focused = .wasHard
        case .wasHard:  focused = .tomorrow
        default:        focused = nil   // nil dismisses the keyboard
        }
    }
}
