//
//  Reflection.swift
//  DailyReflection
//
//  Created by Frank Hakim on 2026/08/16.
//

import Foundation
import SwiftData

@Model
final class Reflection{
    var date :Date
    var wentWell: String
    var wasHard: String
    var tomorrow: String
    
    init(date: Date, wentWell: String, wasHard: String, tomorrow: String) {
        self.date = date
        self.wentWell = wentWell
        self.wasHard = wasHard
        self.tomorrow = tomorrow
    }
    
}
