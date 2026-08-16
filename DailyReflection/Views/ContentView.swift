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
    
    private var todaysEntry: Reflection?{
        let start = Date.now.startOfDay
        let end = Date.now.endOfDay
        return reflections.first{$0.date >= start && $0.date < end}
    }
    
    var body: some View {
        VStack {
            Text("Saved entries: \(reflections.count)")
                .font(.title)
            
            Text(todaysEntry == nil ? "Nothing for today yet" : "Today is done")
                .foregroundStyle(.secondary)
        
            
            Button(todaysEntry == nil ? "Add today" : "Update today"){
                if let entry = todaysEntry{
                    entry.wentWell = "Updated \(Date.now.formatted(date: .omitted, time: .standard))"
                }else {
                    context.insert(Reflection(wentWell: "First entry"))
                }
            }
            .buttonStyle(.borderedProminent)
            
            if let entry = todaysEntry{
                Text(entry.wentWell)
                    .font(.footnote) 
            }
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
