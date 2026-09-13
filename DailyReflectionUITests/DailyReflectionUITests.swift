import Testing
import Foundation
@testable import DailyReflection

struct StreakCalculatorTests {

    /// A date `offset` days before `reference`. Keeps the tests readable.
    private func day(_ offset: Int, before reference: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -offset, to: reference)!
    }

    @Test func noEntriesMeansNoStreak() {
        #expect(StreakCalculator.currentStreak(from: [], today: .now) == 0)
    }

    @Test func writingTodayGivesOne() {
        let today = Date.now
        #expect(StreakCalculator.currentStreak(from: [today], today: today) == 1)
    }

    @Test func threeDaysInARowGivesThree() {
        let today = Date.now
        let dates = [day(0, before: today), day(1, before: today), day(2, before: today)]
        #expect(StreakCalculator.currentStreak(from: dates, today: today) == 3)
    }

    /// The Duolingo rule: nothing written today yet, but yesterday counts.
    @Test func todayUnwrittenKeepsTheStreakAlive() {
        let today = Date.now
        let dates = [day(1, before: today), day(2, before: today)]
        #expect(StreakCalculator.currentStreak(from: dates, today: today) == 2)
    }

    /// Two days missed in a row really does end it.
    @Test func twoDaysMissedEndsTheStreak() {
        let today = Date.now
        #expect(StreakCalculator.currentStreak(from: [day(2, before: today)], today: today) == 0)
    }

    /// Only the run nearest today counts — older runs are history.
    @Test func aGapStopsTheCount() {
        let today = Date.now
        let dates = [day(0, before: today), day(1, before: today),
                     day(3, before: today), day(4, before: today)]
        #expect(StreakCalculator.currentStreak(from: dates, today: today) == 2)
    }

    /// Editing morning and evening is still one day.
    @Test func twoEntriesOnOneDayCountOnce() {
        let today = Date.now
        let morning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: today)!
        let evening = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: today)!
        #expect(StreakCalculator.currentStreak(from: [morning, evening], today: today) == 1)
    }
}
