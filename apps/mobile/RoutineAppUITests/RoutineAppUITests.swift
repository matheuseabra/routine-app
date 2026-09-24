//
//  RoutineAppUITests.swift
//  RoutineAppUITests
//
//  Created by Matheus Seabra on 16/09/26.
//

import XCTest

final class RoutineAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testPaywallLaunchesWithYearlyPlanSelected() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "paywall"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Make progress, one day at a time."].waitForExistence(timeout: 3))
        let yearlyPlan = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Yearly")).firstMatch
        let weeklyPlan = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Weekly")).firstMatch
        XCTAssertTrue(yearlyPlan.waitForExistence(timeout: 3))
        XCTAssertTrue(weeklyPlan.waitForExistence(timeout: 3))
        XCTAssertLessThan(yearlyPlan.frame.minY, weeklyPlan.frame.minY)
        XCTAssertEqual(yearlyPlan.value as? String, "Selected")
        XCTAssertEqual(weeklyPlan.value as? String, "Not selected")
        XCTAssertTrue(yearlyPlan.label.localizedCaseInsensitiveContains("Best value"))
        XCTAssertTrue(yearlyPlan.label.contains("/year"))
        XCTAssertTrue(weeklyPlan.label.contains("/week"))
        let paywallTitle = app.staticTexts["Make progress, one day at a time."]
        XCTAssertEqual(paywallTitle.frame.midX, app.frame.midX, accuracy: 3)
        XCTAssertLessThan(app.staticTexts["Your plan"].frame.midX, app.frame.midX)
        XCTAssertTrue(app.staticTexts["Cancel anytime in the App Store."].exists)
        XCTAssertTrue(app.descendants(matching: .any)["paywall-terms-link"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["paywall-privacy-link"].exists)
        let restore = app.buttons["Restore"]
        XCTAssertTrue(restore.exists)
        XCTAssertEqual(restore.identifier, "paywall-restore-button")
        XCTAssertGreaterThan(restore.frame.minY, weeklyPlan.frame.maxY)
        XCTAssertLessThan(restore.frame.maxY, app.frame.maxY)

        weeklyPlan.tap()
        XCTAssertEqual(weeklyPlan.value as? String, "Selected")
    }

    @MainActor
    func testPlanReadyShowsAnswersAndProgressChart() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "planReady"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Your plan is ready."].waitForExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["Your plan is ready."].frame.midX, app.frame.midX, accuracy: 3)
        XCTAssertTrue(app.staticTexts["Goal"].exists)
        XCTAssertTrue(app.staticTexts["Challenge"].exists)
        XCTAssertTrue(app.staticTexts["Your progress over time"].exists)
        XCTAssertTrue(app.staticTexts["Without Routine"].exists)
        XCTAssertTrue(app.staticTexts["With Routine"].exists)
        XCTAssertTrue(app.buttons["Continue"].exists)
    }

    @MainActor
    func testAddTaskSheetHasNoCloseButton() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "main"]
        app.launch()

        app.buttons["Add task"].tap()
        XCTAssertTrue(app.textFields["Task name"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Close"].exists)
    }

    @MainActor
    func testMainNavigationOpensSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "main"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Today"].waitForExistence(timeout: 3))
        app.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Profile"].waitForExistence(timeout: 2))
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testNameStepStartsPlanGeneration() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "quiz", "-quiz-question", "5"]
        app.launch()

        XCTAssertTrue(app.staticTexts["What should we call you?"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Next up —"].exists)
        XCTAssertFalse(app.buttons["Create my plan"].isEnabled)
        let nameField = app.textFields["Your name"]
        nameField.tap()
        nameField.typeText("Matheus")
        XCTAssertTrue(app.buttons["Create my plan"].isEnabled)
        app.buttons["Create my plan"].tap()
        XCTAssertTrue(app.staticTexts["Creating your personal plan..."].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Matheus, your plan is ready."].waitForExistence(timeout: 6))
    }

    @MainActor
    func testQuizQuestionOneUsesReferenceOutcomeChoices() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "quiz", "-quiz-question", "1"]
        app.launch()

        XCTAssertTrue(app.staticTexts["What would you like to improve first?"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Stay more consistent"].exists)
        XCTAssertTrue(app.buttons["Create a better daily routine"].exists)
        XCTAssertFalse(app.textFields["Your name"].exists)
    }

    @MainActor
    func testQuizConsistencyAndTimeDefaultsMatchReference() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "quiz", "-quiz-question", "3"]
        app.launch()

        XCTAssertTrue(app.staticTexts["How consistent do you feel right now?"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.buttons["Starting again"].value as? String, "Not selected")
        XCTAssertFalse(app.staticTexts["I’m new to this and building the habit."].exists)

        app.terminate()
        app.launchArguments = ["-screen", "quiz", "-quiz-question", "4"]
        app.launch()
        XCTAssertEqual(app.buttons["10–15 minutes"].value as? String, "Not selected")
    }

    @MainActor
    func testWelcomeContinuesToTheFirstQuizStep() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "onboarding"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Build a routine you can keep."].waitForExistence(timeout: 3))
        let progressDots = app.descendants(matching: .any).matching(
            NSPredicate(format: "label == %@", "Page 1 of 5")
        ).firstMatch
        XCTAssertFalse(progressDots.exists)
        app.buttons["Get started"].tap()
        XCTAssertTrue(app.staticTexts["What would you like to improve first?"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testQuizRequiresAnswerBeforeSwipeAdvances() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "quiz"]
        app.launch()

        XCTAssertTrue(app.staticTexts["What would you like to improve first?"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["Continue"].isEnabled)
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["What would you like to improve first?"].exists)
        app.buttons["Stay more consistent"].tap()
        XCTAssertTrue(app.buttons["Continue"].isEnabled)
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["What usually gets in the way?"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testQuizBackButtonReturnsToOnboardingFromFirstStep() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "quiz", "-quiz-question", "1"]
        app.launch()

        app.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Build a routine you can keep."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testPlanGenerationAndReadyStagesAreAvailableToTheRouter() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "planGeneration"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Creating your personal plan..."].waitForExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["Creating your personal plan..."].frame.midX, app.frame.midX, accuracy: 3)
        XCTAssertTrue(app.staticTexts["Your plan is ready."].waitForExistence(timeout: 6))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
