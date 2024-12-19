//
//  ModalType.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/4/24.
//

import Foundation

enum ModalType: Identifiable {
    case returningUser
    case tether1
    case tether2
    case completion
    case breakPrompt
    case mindfulness
    case social
    
    var id: String { String(describing: self) }
}
