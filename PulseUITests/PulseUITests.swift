import XCTest

final class PulseUITests: XCTestCase {
    func testTestsAndResultsTabsAreReachable() {
        let app = XCUIApplication()
        app.launchArguments = ["-skipOnboarding"]
        app.launch()

        let testsTab = app.tabBars.buttons["Tests"]
        let resultsTab = app.tabBars.buttons["Results"]

        XCTAssertTrue(testsTab.waitForExistence(timeout: 5))
        XCTAssertTrue(resultsTab.exists)
        XCTAssertTrue(app.buttons["runAllTestsButton"].waitForExistence(timeout: 5))

        resultsTab.tap()
        XCTAssertTrue(app.navigationBars["Results"].waitForExistence(timeout: 5))
    }
}
