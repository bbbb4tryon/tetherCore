//
//  StorageManagerError.swift
//  Tether
//
//  Created by Benjamin Tryon on 12/21/24.
//

import SwiftUI

enum StorageManagerError: Error {
    case failedLoading, failedSave, encodingFailure, decodingFailure, invalidDataFormat, storageAccessDenied
    
    
}
extension StorageManagerError {
    var message: String {
        switch self {
        case .failedLoading: return "Unable to load saved data"
        case .failedSave: return "Unable to save data"
        case .encodingFailure: return "Unable to process data for saving"
        case .decodingFailure: return "Unable to read saved data"
        case .invalidDataFormat: return "Data format is invalid"
        case .storageAccessDenied: return "Cannot access storage"
        }
    }
}

extension StorageManagerError: LocalizedError {
    public var localizedDesc: String { message }
    
    public var failureReason: String? {
        switch self {
        case .failedLoading: return "Data could not be loaded from storage"
        case .failedSave: return "Data could not be saved to storage"
        case .encodingFailure: return "Data conversion failed"
        case .decodingFailure: return "Saved data is corrupted"
        case .invalidDataFormat: return "Data structure is incorrect"
        case .storageAccessDenied: return "Storage permissions issue"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .failedLoading: return "Close and reopen the app"
        case .failedSave: return "Check available storage space on your device and try again"
        case .encodingFailure: return "Re-entering your data"
        case .decodingFailure: return "Clear app data in Settings"
        case .invalidDataFormat: return "Close and reopen the app"
        case .storageAccessDenied: return "Check the app has necessary settings in your device Settings"
        }
    }
}
