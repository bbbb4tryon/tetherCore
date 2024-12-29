//
//  TetherUITests.swift
//  TetherUITests
//
//  Created by Benjamin Tryon on 12/3/24.
//

import XCTest
import OSLog
@testable import Tether

final class AppButtons: XCTestCase {
    @MainActor func testButtonExists() throws {     ///NOTE: MainActor needed if Type is Decorated with it
        ///Arrange
        let sut = CoreView()
        logger.debug("Starting button test")        /// Uses the TestHelpers extension
        
        ///Act
        XCTAssertFalse(sut.buttonWasPressed)    /// Confirm initial state is false
        logger.debug("Initial state verified")
        sut.buttonWasPressed = true             /// SIMULATE button press
        
        ///Assert
        XCTAssertTrue(sut.buttonWasPressed)     /// State AFTER press
        logger.debug("Button press verified")
    }
}
