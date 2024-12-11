//
//  SocialError.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/11/24.
//

import SwiftUI

enum SocialError: Error {
    case platformUnavailable
    case sharingFailed(platform: SocialPlatform)
    case noContentToShare
    case authenticationRequired
    case regionRestricted
}

extension SocialError: GlobalError {
    var message: String {
        switch self {
        case .platformUnavailable: return "This platform is not available on your device"
                case .sharingFailed(let platform): return "Failed to share to \(platform.rawValue)"
                case .noContentToShare: return "No content available to share"
                case .authenticationRequired: return "Please log in to share"
                case .regionRestricted: return "This platform is not available in your region"
        }
    }
}

extension SocialError: LocalizedError {
    public var localizedDescription: String { message }
    
    public var failureReason: String? {
        switch self {
               case .platformUnavailable: return "The app is not installed or configured"
               case .sharingFailed: return "Network or permission error occurred"
               case .noContentToShare: return "Content validation failed"
               case .authenticationRequired: return "Authentication required"
               case .regionRestricted: return "Regional restrictions apply"
        }
    }
    public var recoverySuggestion: String? {
        switch self {
               case .platformUnavailable: return "Install the app or check system settings"
               case .sharingFailed: return "Try again"
               case .noContentToShare: return "Complete all tethers before sharing"
               case .authenticationRequired: return "Sign into your account"
               case .regionRestricted: return "Try an available platform in your region"
        }
    }
}

