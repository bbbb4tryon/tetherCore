//
//  InputValidationError.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/23/24.
//

import SwiftUI

enum InputValidationError: Error {
    case emptyText, invalidLength
}

extension InputValidationError: GlobalError {
    var message: String {
        switch self {
        case .emptyText: return "Text field cannot be empty"
        case .invalidLength: return "160 character limit"
        }
    }
}

extension InputValidationError: LocalizedError {
    public var localizedDescription: String { message }
    
    public var failureReason: String? {
        switch self {
        case .emptyText: return "Required field (text field) was left empty"
        case .invalidLength: return "Text length was outside allowed range of 160 characters"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .emptyText: return "Please enter your text"
        case .invalidLength: return "Adjust length under 160 characters to continue"
        }
    }
}
