//
//  DailyReflectionApp.swift
//  DailyReflection
//
//  Created by Frank Hakim on 2026/08/16.
//

import SwiftUI
import SwiftData

@main
struct DailyReflectionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Reflection.self)
    }
}
