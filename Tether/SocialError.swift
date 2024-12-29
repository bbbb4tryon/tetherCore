//
//  SocialError.swift
//  Tether
//
//  Created by Benjamin Tryon on 12/11/24.
//

import SwiftUI

enum SocialError: Error {
    case platformUnavailable       /// Retry flag for temporary issues
    case networkUnavailable
    case sharingFailed(platform: SocialPlatform)
    case noContentToShare
    case authenticationRequired
    case regionRestricted
    case invalidURL(platform: String, reason: String)
    
}

extension SocialError: GlobalError {
    var message: String {
        switch self {
        case .platformUnavailable: return "This platform is not available on your device"
        case .networkUnavailable: return "Network issue."
                case .sharingFailed(let platform): return "Failed to share to \(platform.rawValue)"
                case .noContentToShare: return "No content available to share"
                case .authenticationRequired: return "Please log in to share"
                case .regionRestricted: return "This platform is not available in your region"
                case .invalidURL: return "This platform URL is not valid"
        }
    }
}

extension SocialError: LocalizedError {
    public var localizedDescription: String { message }
    
    public var failureReason: String? {
        switch self {
               case .platformUnavailable: return "The app is not installed or configured"
        case .networkUnavailable: return "No network"
               case .sharingFailed: return "Network or permission error occurred"
               case .noContentToShare: return "Content validation failed"
               case .authenticationRequired: return "Authentication required"
               case .regionRestricted: return "Regional restrictions apply"
            case .invalidURL: return "Invalid"
        }
    }
    public var recoverySuggestion: String? {
        switch self {
               case .platformUnavailable: return "Install the app or check system settings"
        case .networkUnavailable: return "Refresh app"
               case .sharingFailed: return "Try again"
               case .noContentToShare: return "Complete all tethers before sharing"
               case .authenticationRequired: return "Sign into your account"
               case .regionRestricted: return "Try an available platform in your region"
                case .invalidURL: return "Check input"
        }
    }
}

