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
    func testPaywallLaunchesWithWeeklyPlanSelected() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "paywall"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Invest in better habits."].waitForExistence(timeout: 3))
        XCTAssertEqual(app.buttons["Weekly, $9.99 / week"].value as? String, "Selected")
    }

    @MainActor
    func testTrialReminderPaywallContinuesThroughRemindersToPlanSelection() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "paywall2"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Your trial timeline."].waitForExistence(timeout: 3))
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.staticTexts["Never miss a moment."].waitForExistence(timeout: 2))
        app.buttons["Not now"].tap()
        XCTAssertTrue(app.staticTexts["Invest in better habits."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testAddTaskSheetHasNoCloseButton() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "main"]
        app.launch()

        app.buttons["Add"].tap()
        XCTAssertTrue(app.textFields["Task name"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Close"].exists)
    }

    @MainActor
    func testMainNavigationOpensSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "main"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Nothing planned yet"].waitForExistence(timeout: 3))
        app.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Profile"].waitForExistence(timeout: 2))
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testQuizCompletesDirectlyToPlan() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "quiz", "-quiz-question", "5"]
        app.launch()

        XCTAssertTrue(app.staticTexts["What would help you\nstay consistent?"].waitForExistence(timeout: 3))
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.staticTexts["A clearer path\nto your goals."].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["your plan\nis ready."].exists)
    }

    @MainActor
    func testQuizQuestionTwoUsesMultipleChoiceCards() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "quiz", "-quiz-question", "2"]
        app.launch()

        XCTAssertTrue(app.staticTexts["What are your\nmain goals?"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Better focus"].exists)
        XCTAssertTrue(app.buttons["Stay organized"].exists)
        XCTAssertFalse(app.staticTexts["Next up:"].exists)
    }

    @MainActor
    func testOnboardingSwipeAdvancesToTheNextSlide() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "onboarding"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Build better habits,\none day at a time."].waitForExistence(timeout: 3))
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["Make time for\nwhat matters."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testQuizSwipeAdvancesToTheNextQuestion() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "quiz"]
        app.launch()

        XCTAssertTrue(app.staticTexts["What should we\ncall you?"].waitForExistence(timeout: 3))
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["What are your\nmain goals?"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testPlanSwipeAdvancesToAuthentication() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "plan"]
        app.launch()

        XCTAssertTrue(app.staticTexts["A clearer path\nto your goals."].waitForExistence(timeout: 3))
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["Save your progress."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
