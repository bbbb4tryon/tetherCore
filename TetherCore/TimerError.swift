//
//  TimerError.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/22/24.
//

import SwiftUI

enum TimerError: Error {
    case initializationFailure, invalidStateTransition, coordinatorNotSet, taskCancelled
}
extension TimerError: GlobalError {
    var message: String {
        switch self {
        case .initializationFailure: return "Timer setup failed"
        case .invalidStateTransition: return "Invalid timer state"
        case .coordinatorNotSet: return "Timer system not ready"
        case .taskCancelled: return "Timer operation cancelled"
        }
    }
}

extension TimerError: LocalizedError {
    public var localizedDescription: String { message }
    
    public var failureReason: String? {
        switch self {
        case .initializationFailure: return "Timer could not be initialized"
        case .invalidStateTransition: return "Timer state is invalid"
        case .coordinatorNotSet: return "Timer coordinator not configured"
        case .taskCancelled: return "Timer task was cancelled"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .initializationFailure: return "Restart the app"
        case .invalidStateTransition: return "Reset timer and try again"
        case .coordinatorNotSet: return "Close app and reopen"
        case .taskCancelled: return "Start a new timer"
        }
    }
}
