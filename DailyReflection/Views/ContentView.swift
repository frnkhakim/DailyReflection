//
//  ContentView.swift
//  DailyReflection
//
//  Created by Frank Hakim on 2026/08/16.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Reflection.date, order: .reverse)
    private var reflections: [Reflection]
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack {
            Text("Saved entries: \(reflections.count)")
                .font(.title)
            
            Button("Add test entry"){
                let entry = Reflection(wentWell: "Started app 15")
                context.insert(entry)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        // Previews don't run your App struct, so they never get the real
        // database. inMemory: true builds a throwaway one that dies when
        // the preview closes — so preview data never touches the real app.
        .modelContainer(for: Reflection.self, inMemory: true)
}
