import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \Reflection.date, order: .reverse)
    private var reflections: [Reflection]
    
    /// Entries grouped into months, newest month first.
    /// Dictionaries are unordered, so we sort and hand back an array.
    private var months: [(key: Date, entries: [Reflection])] {
        Dictionary(grouping: reflections) { $0.date.startOfMonth }
            .sorted { $0.key > $1.key }
            .map { (key: $0.key, entries: $0.value) }
    }

    var body: some View {
        Group {
            if reflections.isEmpty {
                // Apple's standard empty state — matches Mail, Photos, Files.
                ContentUnavailableView(
                    "No reflections yet",
                    systemImage: "book.closed",
                    description: Text("Entries appear here once you write your first one.")
                )
            } else {
                List {
                    ForEach(months, id: \.key) { month in
                        // "September 2026" — localised automatically.
                        Section(month.key.formatted(.dateTime.month(.wide).year())) {
                            ForEach(month.entries) { entry in
                                NavigationLink {
                                    ReflectionDetailView(reflection: entry)
                                } label: {
                                    ReflectionRow(reflection: entry)
                                }
                            }
                            // offsets are relative to THIS section, not the whole query.
                            .onDelete { offsets in
                                delete(offsets, from: month.entries)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    MonthGridView()
                } label: {
                    Label("Calendar", systemImage: "calendar")
                }
            }
        }
    }
    
    /// Deletes swiped rows. `offsets` index into the section's array,
    /// which is why the caller passes it in — indexing `reflections`
    /// here would delete the wrong entries once there's a second month.
    private func delete(_ offsets: IndexSet, from entries: [Reflection]) {
        for index in offsets {
            context.delete(entries[index])
        }
    }
}
