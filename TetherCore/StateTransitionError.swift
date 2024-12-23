//
//  StateTransitionError.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/23/24.
//

import SwiftUI

enum StateTransitionError: Error {
    case invalidStateChange
    case incompletePreviousState
    case stateNotRestorable
}

extension StateTransitionError: GlobalError {
    var message: String {
        switch self {
        case .invalidStateChange: return "Cannot perform this action now"
        case .incompletePreviousState: return "Previous step not completed"
        case .stateNotRestorable: return "Cannot restore previous state"
        }
    }
}

extension StateTransitionError: LocalizedError {
    public var localizedDescription: String { message }
    
    public var failureReason: String? {
        switch self {
        case .invalidStateChange: "App state cannot change from current activity"
        case .incompletePreviousState: "Previous steps were not marked as complete"
        case .stateNotRestorable: "Saved state data on device is incomplete/corrupted"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidStateChange: "Return to home screen and start a new session"
        case .incompletePreviousState: "Complete your current tether before moving to next one"
        case .stateNotRestorable: "Start a new session"
        }
    }
}
