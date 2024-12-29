//
//  TestHelpers.swift
//  TetherTests
//
//  Created by Benjamin Tryon on 12/4/24.
//

import XCTest
import OSLog

extension XCTestCase {
    var logger: Logger {
        Logger(subsystem: "com.Tether.tests", category: String(describing: self))
    }
}
