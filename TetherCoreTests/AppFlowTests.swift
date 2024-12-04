//
//  AppFlowTests.swift
//  TetherCoreUITests
//
//  Created by Benjamin Tryon on 12/3/24.
//

import XCTest
import OSLog
@testable import TetherCore

final class AppFlowTests: XCTestCase {
    /// find the app
    var app: XCUIApplication!

    override func setUpWithError() throws {
        super.setUp()
        // UI tests must launch the application that they test.
        app = XCUIApplication()
        continueAfterFailure = false
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testSubmitButtonFlow() throws {
        let textField = app.textFields["Required"]      //Identifier
        let submitButton = app.buttons["Done"]        //Identifier
        
        ///First submission
        textField.tap()
        textField.typeText("First Input")           ///Or use the Logger?
        submitButton.tap()
        
        /// Verify no navigation happened yet
        XCTAssertFalse(app.navigationBars["Profile"].exists)
        
        ///Second submission
        textField.tap()
        textField.typeText("Second Input")
        submitButton.tap()
        
        ///Verify navigation occurred
        XCTAssertTrue(app.navigationBars["Profile"].exists)
        
        ///Verify modal appeared
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 2))
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        //NOTE: for the above to occur, you need to add .accessibilityIdentifier() to the Views.
    }
}
