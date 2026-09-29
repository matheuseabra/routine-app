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

    @Test func routerIgnoresMissingAndUnknownScreenOverrides() {
        let missingScreen = AppRouter(
            arguments: ["RoutineApp", "-screen"],
            hasCompletedOnboarding: true
        )
        #expect(missingScreen.screen == .paywall)
        #expect(!missingScreen.usesScreenOverride)

        let unknownScreen = AppRouter(arguments: ["RoutineApp", "-screen", "unknown"])
        #expect(unknownScreen.screen == .launch)
        #expect(!unknownScreen.usesScreenOverride)
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

    @Test func routerAdvancesAndReturnsToLaunchAtFlowBoundaries() {
        let router = AppRouter(arguments: ["RoutineApp"])
        router.goBack(authEnabled: false)
        #expect(router.screen == .launch)

        router.advance(authEnabled: false)
        #expect(router.screen == .onboarding)
        router.advance(authEnabled: false)
        #expect(router.screen == .quiz)
        router.goBack(authEnabled: false)
        #expect(router.screen == .onboarding)
        router.goBack(authEnabled: false)
        #expect(router.screen == .launch)
        router.goBack(authEnabled: false)
        #expect(router.screen == .launch)

        let main = AppRouter(arguments: ["RoutineApp", "-screen", "main"])
        main.advance(authEnabled: false)
        #expect(main.screen == .main)
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

    @Test func routerBackNavigationRespectsAuthenticationSetting() {
        let planGeneration = AppRouter(arguments: ["RoutineApp", "-screen", "planGeneration"])
        planGeneration.goBack(authEnabled: false)
        #expect(planGeneration.screen == .quiz)

        let planReady = AppRouter(arguments: ["RoutineApp", "-screen", "planReady"])
        planReady.goBack(authEnabled: false)
        #expect(planReady.screen == .quiz)

        let authentication = AppRouter(arguments: ["RoutineApp", "-screen", "authentication"])
        authentication.goBack(authEnabled: true)
        #expect(authentication.screen == .planReady)

        let trialWithAuthentication = AppRouter(arguments: ["RoutineApp", "-screen", "trialExplainer"])
        trialWithAuthentication.goBack(authEnabled: true)
        #expect(trialWithAuthentication.screen == .authentication)

        let trialWithoutAuthentication = AppRouter(arguments: ["RoutineApp", "-screen", "trialExplainer"])
        trialWithoutAuthentication.goBack(authEnabled: false)
        #expect(trialWithoutAuthentication.screen == .planReady)

        let reminder = AppRouter(arguments: ["RoutineApp", "-screen", "reminder"])
        reminder.goBack(authEnabled: false)
        #expect(reminder.screen == .trialExplainer)

        let paywall = AppRouter(arguments: ["RoutineApp", "-screen", "paywall"])
        paywall.goBack(authEnabled: false)
        #expect(paywall.screen == .reminder)

        let main = AppRouter(arguments: ["RoutineApp", "-screen", "main"])
        main.goBack(authEnabled: false)
        #expect(main.screen == .paywall)
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

    @Test func returningUserWithoutEntitlementStaysAtPaywall() {
        let router = AppRouter(arguments: ["RoutineApp"], hasCompletedOnboarding: true)
        router.resolveReturningSession(hasActiveEntitlement: false)
        #expect(router.screen == .paywall)
    }

    @Test func screenOverrideIsPreservedWhenReturningSessionResolves() {
        let router = AppRouter(arguments: ["RoutineApp", "-screen", "planReady"])
        router.resolveReturningSession(hasActiveEntitlement: true)
        #expect(router.screen == .planReady)
        #expect(router.usesScreenOverride)
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

    @Test func appStateTrimsAndPersistsAUserName() throws {
        let suiteName = "RoutineAppTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let state = AppState(defaults: defaults)
        state.completeOnboarding(userName: "  Alex\n")
        state.completeOnboarding(userName: " \t ")

        let restoredState = AppState(defaults: defaults)
        #expect(restoredState.hasCompletedOnboarding)
        #expect(restoredState.userName == "Alex")
    }

    @Test func appStateResetClearsPersistedOnboardingAndName() throws {
        let suiteName = "RoutineAppTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let state = AppState(defaults: defaults)
        state.completeOnboarding(userName: "Alex")
        state.resetOnboarding()

        let restoredState = AppState(defaults: defaults)
        #expect(!restoredState.hasCompletedOnboarding)
        #expect(restoredState.userName.isEmpty)
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
        #expect(plan.goalAnswer == "Stay more consistent")
        #expect(plan.challengeAnswer == "I struggle with consistency")
        #expect(plan.consistencyAnswer == "Starting again")
        #expect(plan.timeAnswer == "10–15 minutes")

        let incompletePlan = RoutinePlanContext(name: " \n ", answers: [""])
        #expect(incompletePlan.readyTitle == "Your plan is ready.")
        #expect(incompletePlan.goalAnswer == "Stay more consistent")
        #expect(incompletePlan.challengeAnswer == "I struggle with consistency")
        #expect(incompletePlan.consistencyAnswer == "Starting again")
        #expect(incompletePlan.timeAnswer == "10–15 minutes")
    }

    @Test func planGoalPhraseMapsEveryKnownChoiceAndCustomAnswers() {
        let examples = [
            ("Stay more consistent", "build stronger consistency"),
            ("Get more done", "get more done"),
            ("Feel more focused", "feel more focused"),
            ("Build healthier habits", "build healthier habits"),
            ("Create a better daily routine", "create a better daily routine"),
            ("Find my rhythm", "find my rhythm")
        ]

        for (answer, expectedPhrase) in examples {
            let plan = RoutinePlanContext(name: "  Alex  ", answers: [answer])
            #expect(plan.goalPhrase == expectedPhrase)
        }

        let plan = RoutinePlanContext(
            name: "  Alex  ",
            answers: ["Feel more focused", "Too many distractions", "Getting there", "5 minutes"]
        )
        #expect(plan.readyTitle == "Alex, your plan is ready.")
        #expect(plan.challengeAnswer == "Too many distractions")
        #expect(plan.consistencyAnswer == "Getting there")
        #expect(plan.timeAnswer == "5 minutes")
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

    @Test func insightSummaryIsEmptyWithoutCheckIns() {
        let summary = InsightSummary.make(checkIns: [], calendar: Calendar(identifier: .gregorian))

        #expect(summary.completedCount == 0)
        #expect(summary.currentStreak == 0)
        #expect(summary.consistency == 0)
    }

    @Test func insightSummaryDeduplicatesDaysAndStopsStreakAtAGap() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        let eightDaysAgo = calendar.date(byAdding: .day, value: -8, to: today)!
        let taskID = UUID()
        let checkIns = [
            RoutineCheckIn(taskID: taskID, completedAt: today),
            RoutineCheckIn(taskID: taskID, completedAt: today),
            RoutineCheckIn(taskID: taskID, completedAt: yesterday),
            RoutineCheckIn(taskID: taskID, completedAt: threeDaysAgo),
            RoutineCheckIn(taskID: taskID, completedAt: eightDaysAgo)
        ]

        let summary = InsightSummary.make(checkIns: checkIns, calendar: calendar)

        #expect(summary.completedCount == 5)
        #expect(summary.currentStreak == 2)
        #expect(summary.consistency == 43)
    }

    @Test func insightSummaryContinuesAStreakFromYesterday() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today)!
        let checkIns = [
            RoutineCheckIn(taskID: UUID(), completedAt: yesterday),
            RoutineCheckIn(taskID: UUID(), completedAt: dayBeforeYesterday)
        ]

        let summary = InsightSummary.make(checkIns: checkIns, calendar: calendar)

        #expect(summary.currentStreak == 2)
        #expect(summary.consistency == 29)
    }
}
