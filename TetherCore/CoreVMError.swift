//
//  CoreVMError.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/2/24.
//

import SwiftUI

/// Concrete Type of GlobalError protocol
/// /// [Type: Enum CoreVMError]
/// [Conformance: Error, GlobalError, LocalizedError]
/// [Called by: CoreViewModel.generic()]
/// [Caller: CoreView alert binding]
/// [->Output: String messages for error display]
///
/// Handles storage-related errors in the core view model.
/// Provides localized error messages and recovery suggestions.
///
/// Usage:
///   ```
///   self.error = CoreVMError.storageFailure
///   ```
enum CoreVMError: Error {
    case storageFailure
}
extension CoreVMError: GlobalError {
    var message: String {
        switch self {
        case .storageFailure: return "Unsuccessful addition to storage"
        }
    }
}
extension CoreVMError: LocalizedError {
    public var localizedDesc: String {
       message
    }
    public var failureReason: String? {
        switch self {
        case .storageFailure: return String(localized: "Why")
        }
    }
    public var recoverySuggestion: String? {
        switch self {
        case .storageFailure: return String(localized: "Refresh the app")
        }
    }
}

