import XCTest

final class EmptyStateUITests: XCTestCase {
    @MainActor
    func testEmptyTabsStayCenteredWithoutDashboardLinks() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "main", "-empty-data"]
        app.launch()

        let homeTitle = app.staticTexts["Start with one small step"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 3))
        XCTAssertEqual(homeTitle.frame.midX, app.frame.midX, accuracy: 3)
        let homeCenter = homeTitle.frame.midX

        app.buttons["Habits"].tap()
        let habitsTitle = app.staticTexts["Build your first habit"]
        XCTAssertTrue(habitsTitle.waitForExistence(timeout: 2))
        XCTAssertEqual(habitsTitle.frame.midX, homeCenter, accuracy: 3)

        app.buttons["Insights"].tap()
        let insightsTitle = app.staticTexts["Your first check-in starts here"]
        XCTAssertTrue(insightsTitle.waitForExistence(timeout: 2))
        XCTAssertEqual(insightsTitle.frame.midX, app.frame.midX, accuracy: 3)
        XCTAssertFalse(app.buttons["View your dashboard"].exists)
        app.buttons["Home"].tap()
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 2))

        app.buttons["Profile"].tap()
        let historyTitle = app.staticTexts["No check-ins yet"]
        XCTAssertTrue(historyTitle.waitForExistence(timeout: 2))
        XCTAssertEqual(historyTitle.frame.midX, app.frame.midX, accuracy: 3)
        XCTAssertFalse(app.buttons["View your dashboard"].exists)
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 2))
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSearchShowsContextualEmptyResults() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "main", "-empty-data"]
        app.launch()
        app.buttons["Search tasks"].tap()
        XCTAssertTrue(app.staticTexts["Find a task"].waitForExistence(timeout: 2))
        let search = app.searchFields["Search tasks"]
        search.tap()
        search.typeText("Morning walk")
        XCTAssertTrue(app.staticTexts["No tasks found"].waitForExistence(timeout: 2))
    }
}
