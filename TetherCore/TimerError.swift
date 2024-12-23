//
//  TimerError.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/22/24.
//

import SwiftUI

enum TimerError: Error {
    case invalidStateTransition, taskCancelled
}
extension TimerError: GlobalError {
    var message: String {
        switch self {
            ///Initialization can't fail: exhaustive enum; each case returns a concrete type implementing TimeProtocol; all return values are actor instantiations; if coordinator is not set, initialization handles it
            ///
        case .invalidStateTransition: return "Invalid timer state"
        case .taskCancelled: return "Timer operation cancelled"
        }
    }
}

extension TimerError: LocalizedError {
    public var localizedDescription: String { message }
    
    public var failureReason: String? {
        switch self {
        case .invalidStateTransition: return "Timer state is invalid"
        case .taskCancelled: return "Timer task was cancelled"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidStateTransition: return "Reset timer and try again"
        case .taskCancelled: return "Start a new timer"
        }
    }
}
