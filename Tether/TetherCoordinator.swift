//
//  TetherCoordinator.swift
//  Tether
//
//  Created by Benjamin Tryon on 12/9/24.
//

import SwiftUI
import Foundation
                                                            ///CoreViewModel already has a tetherCoordinator from init
                                                            ///TimerCoordinator needs both tetherCoordinator and coreVM
                                                            ///TetherCoordinator manages timer lifecycle
                                                            ///Coordinator Pattern to improve modal flow
@MainActor                                                  ///Explicitly MainActor because UI updates
class TetherCoordinator: ObservableObject {
    @Published var currentModal: ModalType?
    @Published private(set) var error: CoordinatorError?    ///Uses published property for error state
    @Published var showClock: Bool = false
    private var timerCoordinator: TimerCoordinator?         ///Correct: Optional & with late initialization
    private let storageManager = StorageManager()           ///StorageManager instance for handleScenePhase)
    //    @Published var total20: Int = 1200
    //    @Published var progress: Float = 0.0
    
    
    ///Method to safely set dependency (avoids leaks)
    func setTimerCoordinator(_ timerCoordinator: TimerCoordinator) {
        self.timerCoordinator = timerCoordinator
    }
    
    func reset() {
        currentModal = nil
        showClock = false
    }
    
    /// init(){} not necessary - all properties have default values
    enum NavigationPath {
        case permissions
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
        case .permissions: currentModal = .permissions
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
    
    func handleClock(_ show: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showClock = show
        }
    }
    
    func handleModalCompletion(for type: ModalType) {
        switch type {
        case .permissions:
            navigate(to: .home)
            HapticStyle.gentle.trigger()
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
    
    func handleReturningUser(_ state: CoreViewModel.TetherState) {
        Task { @MainActor in
            if timerCoordinator == nil {
                error = .timerCoordinatorMissing
                return
            }
            switch state {
            case .firstTether:
                currentModal = .returningUser
            case .secondTether(let coil) where !coil.tether1.isCompleted:
                /// Show tether1 modal
                currentModal = .tether1
            case .secondTether(let coil) where !coil.tether2.isCompleted:
                // Show tether2 modal
                currentModal = .tether2
            default:
                currentModal = nil
            }
        }
    }
    
    func clearError() {
        error = nil
    }
    
    /// Optional, see TimerCoordinator initialization at the top
    func resumeUserTimerFlow() async throws {
        guard let coordinator = timerCoordinator else {
            throw CoordinatorError.timerCoordinatorMissing
        }
        try await timerCoordinator?.resumeUserTimerFlow()
    }
}

@MainActor
extension TetherCoordinator {
    func handleScenePhase(_ phase: ScenePhase) async {
        await timerCoordinator?.handleSceneTransition(phase)
    }
}
