//
//  Date+Day.swift
//  DailyReflection
//
//  Created by Frank Hakim on 2026/08/16.
//

import Foundation

extension Date {
    /// Midnight at the START of this date, in the user's own time zone.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Midnight at the start of the NEXT day. Use as an EXCLUSIVE upper bound.
    var endOfDay: Date {
        // Adding one day to a valid date can't fail, so ! is safe here.
        // Calendar handles daylight saving — don't add 86400 seconds by hand.
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
    }

    /// Midnight on the 1st of this month. Used as a grouping key —
    /// every date in the same month produces the same value.
    var startOfMonth: Date {
        let parts = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: parts)!
    }
    
    /// Number of days in this month — 28, 29, 30 or 31.
    /// Calendar knows the leap-year rules. Never work these out yourself.
    var numberOfDaysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 30
    }
    
    /// Empty cells to draw before the 1st, so dates land in the right column.
    /// firstWeekday is 1 (Sunday) in the US but 2 (Monday) here and in
    /// most of Europe — hardcoding Sunday breaks the layout for most users.
    var leadingBlanks: Int {
        let calendar = Calendar.current
        let weekdayOfFirst = calendar.component(.weekday, from: startOfMonth)
        // +7 then %7 wraps a negative result round instead of going below zero.
        return (weekdayOfFirst - calendar.firstWeekday + 7) % 7
    }
}
