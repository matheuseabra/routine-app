//
//  RoutineAppTests.swift
//  RoutineAppTests
//

import Foundation
import Testing
@testable import RoutineApp

@MainActor
struct RoutineAppTests {
    @Test func routerCanStartAtRequestedScreen() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "paywall"])
        #expect(router.screen == .paywall)
    }

    @Test func routerAdvancesThroughTheProductFlow() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "quiz"])
        router.advance()
        #expect(router.screen == .plan)
    }

    @Test func routerPlacesReminderAfterTrialTimeline() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "paywall2"])
        router.advance()
        #expect(router.screen == .reminder)
        router.advance()
        #expect(router.screen == .paywall)
    }

    @Test func routerNoLongerExposesLockerPaywallScreen() {
        #expect(RoutineScreen(rawValue: "paywall1") == nil)
    }

    @Test func insightSummaryCountsCheckInsAndActiveDays() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let checkIns = [
            RoutineCheckIn(taskID: UUID(), completedAt: today),
            RoutineCheckIn(taskID: UUID(), completedAt: yesterday),
            RoutineCheckIn(taskID: UUID(), completedAt: yesterday)
        ]

        let summary = InsightSummary.make(checkIns: checkIns, calendar: calendar)

        #expect(summary.completedCount == 3)
        #expect(summary.currentStreak == 2)
        #expect(summary.consistency == 29)
    }
}
