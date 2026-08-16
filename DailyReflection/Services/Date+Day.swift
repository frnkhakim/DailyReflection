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
}
