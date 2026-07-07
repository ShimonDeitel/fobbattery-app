import XCTest

final class KeyFobBatteryTrackerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddFlowShowsNewItem() {
        app.buttons["addButton"].tap()
        let nameField = app.textFields["nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("UITest Fob")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["UITest Fob"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<12 {
            app.buttons["addButton"].tap()
            let nameField = app.textFields["nameField"]
            if nameField.waitForExistence(timeout: 1) {
                nameField.tap()
                nameField.typeText("Item \(i)")
                app.buttons["saveButton"].tap()
            }
        }
        XCTAssertTrue(app.buttons["subscribeButton"].waitForExistence(timeout: 2))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["addButton"].tap()
        let nameField = app.textFields["nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Dismiss test")
        app.staticTexts["Note"].tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }
}
