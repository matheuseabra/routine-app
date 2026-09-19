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
        #expect(router.usesScreenOverride)
    }

    @Test func routerAdvancesThroughTheProductFlow() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "quiz"])
        router.advance(authEnabled: false)
        #expect(router.screen == .plan)
    }

    @Test func routerSkipsAuthenticationWhenDisabled() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "plan"])
        router.advance(authEnabled: false)
        #expect(router.screen == .paywall2)
    }

    @Test func routerIncludesAuthenticationWhenEnabled() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "plan"])
        router.advance(authEnabled: true)
        #expect(router.screen == .authentication)
    }

    @Test func returningUserStartsAtPaywallUntilEntitlementResolves() {
        let router = AppRouter(
            arguments: ["RoutineApp"],
            hasCompletedOnboarding: true
        )
        #expect(router.screen == .paywall)

        router.resolveReturningSession(hasActiveEntitlement: true)
        #expect(router.screen == .main)
    }

    @Test func freshUserStartsAtLaunch() {
        let router = AppRouter(
            arguments: ["RoutineApp"],
            hasCompletedOnboarding: false
        )
        #expect(router.screen == .launch)
    }

    @Test func appStatePersistsOnboardingCompletion() throws {
        let suiteName = "RoutineAppTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let state = AppState(defaults: defaults)
        #expect(!state.hasCompletedOnboarding)

        state.completeOnboarding()

        let restoredState = AppState(defaults: defaults)
        #expect(restoredState.hasCompletedOnboarding)
    }

    @Test func routerPlacesReminderAfterTrialTimeline() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "paywall2"])
        router.advance(authEnabled: false)
        #expect(router.screen == .reminder)
        router.advance(authEnabled: false)
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
