//
//  CoordinatorError.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/22/24.
//

import SwiftUI

enum CoordinatorError: Error {
    case timerCoordinatorMissing, invalidStateTransition, concurrentAccessFailure
}

extension CoordinatorError: GlobalError {
    var message: String {
        switch self {
        case .timerCoordinatorMissing: return "Timer not ready"
        case .invalidStateTransition: return "Invalid operation"
        case .concurrentAccessFailure: return "System busy"
        }
    }
}

extension CoordinatorError: LocalizedError {
    public var localizedDescription: String { message }
    
    public var failureReason: String? {
        switch self {
        case .timerCoordinatorMissing: return "Timer coordinator initialization failed"
        case .invalidStateTransition: return "Invalid state change requested"
        case .concurrentAccessFailure: return "Device system not accessible"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .timerCoordinatorMissing: return "Close app completely and reopen"
        case .invalidStateTransition: return "Return to home screen and try again"
        case .concurrentAccessFailure: return "Allow app to access system in Settings, then restart app"
        }
    }
}
