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
    init(
        storage: TetherStorageManager = TetherStorageManager()
    ){
        self.storage = storage
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
                showTimer = true
                startTimer()
                currentModal = .tether1
            }
        }
        currentTetherText = ""
    }
    
    private func startTimer() {
        ///Timer countdown
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ timer in
                if self.timerSeconds > 0 {
                    self.timerSeconds -= 1
                } else {
                    timer.invalidate()
                    self.onTimerComplete()
                }
            }
            /// Timer animation to show
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showTimer = true
            }
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


