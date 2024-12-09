//
//  CoreVM.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import Foundation
import SwiftUI

// MARK: - CoreViewModel
/// CoreViewModel
/// 
@MainActor
class CoreViewModel: ObservableObject {
    @Published private(set) var error: GlobalError?
    @Published var currentTetherText: String = ""
    @Published var currentCoil: Coil?
    @Published var temporaryTether: Tether?
    @Published var showTimer: Bool = false
    @Published var timerSeconds: Int = 1200     /// 20 minutes
    @Published var currentModal: ModalType?
    
    private let storage: TetherStorageManager
    init(testing: Bool = false,
         storage: TetherStorageManager = TetherStorageManager()
    ){
        self.storage = storage
        if testing {
            let tether1 = Tether(tetherText: "Walk the dog")
            let tether2 = Tether(tetherText: "Read a book")
            self.currentCoil = Coil(tether1: tether1, tether2: tether2)
            self.showTimer = true
            self.currentModal = .tether1
        }
    }
    
    /// Flow of tethers/input
    func submitTether() {
        guard !currentTetherText.isEmpty else { return }
        
        let newTether = Tether(tetherText: currentTetherText)
        
        if temporaryTether == nil {
            temporaryTether = newTether
        } else {
            ///Create coil when second tether is submitted/added
            if let firstTether = temporaryTether {
                currentCoil = Coil(tether1: firstTether, tether2: newTether )
                Task {
                    try? await storage.saveCoil(currentCoil!)   ///Save the coil
                }
                temporaryTether = nil
                /// Timer animation to show
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showTimer = true
                }
                startTimer()
                //
            }
        }
        currentTetherText = ""
    }
    
    private func startTimer() {
        ///Timer countdown
        let timer = Timer.publish(every: 1.0, on: .main, in: .common)
               .autoconnect()
               .sink { [weak self] _ in
                   guard let self = self else { return }
                   
                   Task {  // Task to handle sendable closure
                       if self.timerSeconds > 0 {
                           self.timerSeconds -= 1
                       } else {
                           await self.invalidateTimer()
                           self.onTimerComplete()
                       }
                   }
               }
    }
    
    private func invalidateTimer() async {
        Task {  // Task for async operation
            // Stop timer logic
            showTimer = false
        }
    }
    
    func handleModalAction(for type: ModalType, action: ModalAction) {
        switch (type, action) {
        case (.tether1, .complete):
            currentCoil?.tether1.isCompleted = true
            currentModal = .tether2
            
        case (.tether1, .inProgress):
            currentModal = nil
            resetAndStartTimer()
            
        case (.tether2, .complete):
            currentCoil?.tether2.isCompleted = true
            currentModal = .completion
            
        case (.tether2, .inProgress):
            currentModal = nil
            resetAndStartTimer()
            
        case (.completion, .complete):
            // Handle social sharing
            currentModal = .social
            
        case (.completion, .cancel):
            // Go back to home
            resetAll()
            
        case (.social, .complete):
            // Handle social post completion
            resetAll()
            currentModal = nil
        case (.breakPrompt, .complete):
            break
        case (.mindfulness, .complete):
            break
        case (.breakPrompt, .inProgress):
            break
        case (.mindfulness, .inProgress):
            break
        case (.social, .inProgress):
            break
        case (.completion, .inProgress):
            break
        case (_, .cancel):
            currentModal = nil
        }
    }
        
        private func resetAndStartTimer() {
            timerSeconds = 1200
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showTimer = true
            }
            startTimer()
        }
        
        private func resetAll() {
            currentModal = nil
            currentCoil = nil
            temporaryTether = nil
            showTimer = false
            timerSeconds = 1200
        }
        
        /// When Timer is Complete!
        func onTimerComplete() {
            if let coil = currentCoil {
                if !coil.tether1.isCompleted {
                    currentModal = .tether1
                } else if !coil.tether2.isCompleted {
                    currentModal = .tether2
                }
            }
        }
        
        ///[Function][Clear][CoreVM][-> Void]
        func clearTetherUponMistake() {
            temporaryTether = nil
            currentTetherText = ""
        }
        
        /// Manage error state
        func clearError() {
            self.error = nil
        }
        func setError( _ error: any GlobalError) {
            self.error = error
        }
        
        /// Validation
        func genericValidation() throws {
            do {
                try validate()
            } catch {
                self.error = CoreVMError.storageFailure
            }
        }
        func validate(){
            guard !currentTetherText.isEmpty else { return }
            
        }
    }

