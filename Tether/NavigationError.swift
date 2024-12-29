//
//  NavigationError.swift
//  Tether
//
//  Created by Benjamin Tryon on 12/22/24.
//

import SwiftUI

enum NavigationError: Error {
    case invalidTransition, modalPresentationFailed, coordinatorNotInitialized
}

extension NavigationError: GlobalError {
    var message: String {
        switch self {
        case .invalidTransition: return "Unable to navigate to the next screen"
        case .modalPresentationFailed: return "Unable to show the required modal/screen"
        case .coordinatorNotInitialized: return "Navigation system not ready"
        }
    }
}

extension NavigationError: LocalizedError {
    public var localizedDescription: String { message }
    public var failureReason: String? {
        switch self {
        case .invalidTransition: return "Invalid navigation state"
        case .modalPresentationFailed: return "Modal presentation failed"
        case .coordinatorNotInitialized: return "Navigation system initialization failed"
        }
    }
    public var recoverySuggestion: String? {
        switch self {
        case .invalidTransition: return "Return to home screen and try again"
        case .modalPresentationFailed: return "Close the app and reopen"
        case .coordinatorNotInitialized: return "Restart the app"
        }
    }
}

