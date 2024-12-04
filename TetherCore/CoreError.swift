//
//  CoreError.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/2/24.
//

import Foundation

/// ErrorTypes: CoreError
/// case: invalidTetherText
enum CoreError: Error {
    case invalidInput
}
extension CoreError: GlobalError {
    var message: String {
        switch self {
        case .invalidInput: return "Please enter valid text for your focus"
        }
    }
}
extension CoreError: LocalizedError {
    public var localizedDescription: String {
       message
    }
    public var failureReason: String? {
        switch self {
        case .invalidInput: return "Why"
        }
    }
    public var recoverySuggestion: String? {
        switch self {
        case .invalidInput: return String(localized: "If pressing 'Enter' doesn't work, refresh the app")
        }
    }
}
