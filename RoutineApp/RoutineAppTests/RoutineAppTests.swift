//
//  RoutineAppTests.swift
//  RoutineAppTests
//
//  Created by Matheus Seabra on 16/09/26.
//

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

}
