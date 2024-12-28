//
//  ModalType.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/4/24.
//

import Foundation

enum ModalType: String, Codable, Identifiable { /// Conform to Codable using String raw values
    case returningUser
    case tether1
    case tether2
    case completion
    case breakPrompt
    case mindfulness
    case social
    
    var id: String { rawValue }
}
