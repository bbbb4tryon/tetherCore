//
//  TetherCoordinator.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/9/24.
//

import Foundation
///Coordinator Pattern to improve modal flow
class TetherCoordinator: ObservableObject {
    @Published var currentModal: ModalType?
    
    enum NavigationPath {
        case home
        case profile
        case settings
        case tether1Modal
        case tether2Modal
        case completionModal
        case socialModal
    }
    
    func navigate(to path: NavigationPath) {
        switch path {
        case .tether1Modal:
            currentModal = .tether1
        case .tether2Modal:
            currentModal = .tether2
        case .completionModal:
            currentModal = .completion
        case .socialModal:
            currentModal = .social
        case .home, .profile, .settings:
            currentModal = nil
        }
    }
    
    func handleModalCompletion(for type: ModalType) {
        switch type {
        case .tether1:
            navigate(to: .tether2Modal)
        case .tether2:
            navigate(to: .completionModal)
        case .completion:
            navigate(to: .socialModal)
        case .social:
            navigate(to: .home)
        default:
            break
        }
    }
}
