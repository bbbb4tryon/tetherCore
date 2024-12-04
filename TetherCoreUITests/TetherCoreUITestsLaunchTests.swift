//
//  TetherCoreUITestsLaunchTests.swift
//  TetherCoreUITests
//
//  Created by Benjamin Tryon on 12/3/24.
//

import XCTest
import OSLog
@testable import TetherCore

final class TetherCoreUITestsLaunchTests: XCTestCase {
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchPerformance() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI-Testing"] ///Add launch arguments as needed
        
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
            
            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2))    ///Verify launch completed as tested
        }
    }
}
