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
        #expect(router.screen == .planGeneration)
        #expect(RoutineScreen(rawValue: "plan") == nil)
        router.advance(authEnabled: false)
        #expect(router.screen == .planReady)
        router.advance(authEnabled: false)
        #expect(router.screen == .trialExplainer)
        router.advance(authEnabled: false)
        #expect(router.screen == .reminder)
        router.advance(authEnabled: false)
        #expect(router.screen == .paywall)
    }

    @Test func routerSkipsAuthenticationWhenDisabled() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "planReady"])
        router.advance(authEnabled: false)
        #expect(router.screen == .trialExplainer)
    }

    @Test func routerIncludesAuthenticationWhenEnabled() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "planReady"])
        router.advance(authEnabled: true)
        #expect(router.screen == .authentication)
        router.advance(authEnabled: true)
        #expect(router.screen == .trialExplainer)
        router.advance(authEnabled: true)
        #expect(router.screen == .reminder)
        router.advance(authEnabled: true)
        #expect(router.screen == .paywall)
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

    @Test func routerExposesTheCurrentPrePaywallScreens() {
        #expect(RoutineScreen(rawValue: "paywall2") == nil)
        #expect(RoutineScreen(rawValue: "trialExplainer") == .trialExplainer)
        #expect(RoutineScreen(rawValue: "reminder") == .reminder)
    }

    @Test func quizStartsUnansweredAndPlanUsesReferenceFallbacks() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "quiz"])
        #expect(router.quizAnswers.count == 5)
        #expect(router.quizAnswers.allSatisfy { $0 == nil })

        let plan = RoutinePlanContext(name: "", answers: router.quizAnswers)
        #expect(plan.consistencyAnswer == "Starting again")
        #expect(plan.timeAnswer == "10–15 minutes")
    }

    @Test func debugScreenLaunchCanSeedANameForVisualVerification() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "planReady", "-demo-name", "Matheus"])
        #expect(router.name == "Matheus")
        #expect(router.screen == .planReady)
    }

    @Test func routerNoLongerExposesLockerPaywallScreen() {
        #expect(RoutineScreen(rawValue: "paywall1") == nil)
    }

    @Test func unconfiguredSubscriptionProviderDoesNotExposeDemoPlansAsPurchasable() async {
        do {
            _ = try await RevenueCatSubscriptionProvider(apiKey: nil).plans()
            Issue.record("An unconfigured RevenueCat provider must not return purchasable plans.")
        } catch {
            #expect(error is SubscriptionError)
        }
    }

    @Test func completedPurchaseWithConfiguredEntitlementIsSuccessful() throws {
        let outcome = try PurchaseOutcomeResolver.resolve(
            userCancelled: false,
            expectedEntitlementID: "premium",
            activeEntitlementIDs: ["premium"]
        )

        #expect(outcome == .purchased)
    }

    @Test func cancelledPurchaseHasNeutralOutcome() throws {
        let outcome = try PurchaseOutcomeResolver.resolve(
            userCancelled: true,
            expectedEntitlementID: "premium",
            activeEntitlementIDs: []
        )

        #expect(outcome == .cancelled)
    }

    @Test func failedPurchasePropagatesRevenueCatError() throws {
        struct PurchaseFailure: Error, Equatable {}
        let expectedError = PurchaseFailure()

        do {
            _ = try PurchaseOutcomeResolver.resolve(
                userCancelled: false,
                purchaseError: expectedError,
                expectedEntitlementID: "premium",
                activeEntitlementIDs: []
            )
            Issue.record("RevenueCat purchase errors must be surfaced to the paywall.")
        } catch let error as PurchaseFailure {
            #expect(error == expectedError)
        } catch {
            Issue.record("Unexpected purchase error type.")
        }
    }

    @Test func completedPurchaseWithWrongEntitlementReportsConfigurationMismatch() throws {
        do {
            _ = try PurchaseOutcomeResolver.resolve(
                userCancelled: false,
                expectedEntitlementID: "premium",
                activeEntitlementIDs: ["pro"]
            )
            Issue.record("A completed purchase without the configured entitlement must fail explicitly.")
        } catch let error as SubscriptionError {
            #expect(error == .entitlementNotActivated(expected: "premium", active: ["pro"]))
        }
    }

    @Test func releaseBuildRejectsTestStoreAndSecretSDKKeys() {
        #expect(RevenueCatSDKKeyPolicy.clientKey(from: "test_example", allowTestStore: false) == nil)
        #expect(RevenueCatSDKKeyPolicy.clientKey(from: "test_example", allowTestStore: true) == "test_example")
        #expect(RevenueCatSDKKeyPolicy.clientKey(from: "sk_example", allowTestStore: true) == nil)
        #expect(RevenueCatSDKKeyPolicy.clientKey(from: "appl_example", allowTestStore: false) == "appl_example")
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
