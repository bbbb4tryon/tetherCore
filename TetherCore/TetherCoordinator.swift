//
//  TetherCoordinator.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/9/24.
//

import SwiftUI
import Foundation
///Coordinator Pattern to improve modal flow
class TetherCoordinator: ObservableObject {
    @Published var currentModal: ModalType?
    @Published var showTimer: Bool = false
    @Published var timerValue: Int = 1200
    
    enum NavigationPath {
        case home
        case profile
        case settings
        case tether1Modal
        case tether2Modal
        case completionModal
        case socialModal
    }
    
    func reset() {
        currentModal = nil
        showTimer = false
    }
    
    func navigate(to path: NavigationPath) {
        switch path {
        case .home: currentModal = nil
        case .profile: currentModal = nil
        case .settings: currentModal = nil
        case .tether1Modal: currentModal = .tether1
        case .tether2Modal: currentModal = .tether2
        case .completionModal: currentModal = .completion
        case .socialModal: currentModal = .social
        }
    }
    
    func dismissModal() {
        currentModal = nil
    }
    
    func showTimer(_ show: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showTimer = show
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
