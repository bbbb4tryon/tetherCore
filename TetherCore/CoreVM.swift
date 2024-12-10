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
    
    enum TetherState {
        case empty                  /// Nothing entered
        case firstTether(Tether)    /// First Tether entered
        case secondTether(Coil)     /// Both tethers in coil, not completed
        case completed(Coil)        /// Coil with completion status
    }
    @Published private(set) var currentState: TetherState = .empty
    @Published var currentTetherText: String = ""
    @Published var currentModal: ModalType?
    
    @Published private(set) var error: GlobalError?
    @Published var timerSeconds: Int = 1200     /// 20 minutes
//    testing: Bool = false; @Published var isTesting: Bool = false;  self.isTesting = testing  /// Track testing state; if testing {
//        setupTestData()
//    }
    
    private let storage: TetherStorageManager
    private let mainTimer: TimerActor   /// [Property][Actor][CoreVM][-> Timer]
    
    init(
         storage: TetherStorageManager = TetherStorageManager()
    ){
        self.storage = storage
        self.mainTimer = TimerActor()   ///Initialize timer actor
    }
    
    //MARK: Computed Properties
    var isTether1Completed: Bool {
        if case .completed(let coil) = currentState {
            return coil.tether1.isCompleted
        }
        return false
    }
    /// New:
    /// `if case` pattern matching ensures valid state
    var isTether2Completed: Bool {
        if case .completed(let coil) = currentState {
            return coil.tether2.isCompleted
        }
        return false
    }
    // OLD:
    //    /// Completion Status Difference:
    //    var isTether2Completed: Bool {
    //        currentCoil?.tether2.isCompleted == true  ///Optional chaining could be nil
    //    }
    
    
    
    //MARK: Actions
    /// Flow of tethers/input
    func submitTether() {
        guard !currentTetherText.isEmpty else { return }
        let newTether = Tether(tetherText: currentTetherText)
        
        switch currentState {
        case .empty:
            currentState = .firstTether(newTether)
        case .firstTether(let firstTether):
            let coil = Coil(tether1: firstTether, tether2: newTether)
            currentState = .secondTether(coil)
            Task {
                try? await storage.saveCoil(coil)
                await startTimer()
                currentModal = .tether1
            }
        default:
            break
        }
        currentTetherText = ""
    }

    
    // MARK: Timer Management
    /// "Timer Management"
    private func startTimer() async {   /// [Function][Timer][CoreVM][-> Void]
        await mainTimer.start {
            Task {
                self.timerSeconds -= 1
                if self.timerSeconds == 0 {
                    self.onTimerComplete()
                }
            }
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showTimer = true
        }
    }
    
    private func resetAndStartTimer() { /// [Function][Timer][CoreVM][->Void]
        timerSeconds = 1200
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showTimer = true
        }
        Task { await startTimer() }
    }
    
    private func pauseTimer() async {    /// [Function][Timer][CoreVM][-> Void]
        await mainTimer.pause()
        showTimer = false
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
    /// State and UI
    func resetAll() {
        ///Use TimerActor to stop timer completely
        Task {
            await mainTimer.stop()
            currentState = .empty
            currentModal = nil
        }
    }
    
//    ///Testing Data Management
//    private func setupTestData() {
//        let tether1 = Tether(tetherText: "Walk the dog")
//        let tether2 = Tether(tetherText: "Read a book")
//        self.currentCoil = Coil(tether1: tether1, tether2: tether2)
//        self.showTimer = true
//        self.currentModal = .tether1
//    }
    
    //MARK: Modal Actions Management
    func handleModalAction(for type: ModalType, action: ModalAction) {
        switch (type, action) {
        case (.tether1, .complete):
            currentCoil?.tether1.isCompleted = true
            currentModal = .tether2
            
        case (.tether1, .inProgress):
            currentModal = nil
            Task { await pauseTimer() }
            resetAndStartTimer()
            
        case (.tether2, .complete):
            currentCoil?.tether2.isCompleted = true
            currentModal = .completion
            
        case (.tether2, .inProgress):
            currentModal = nil
            Task { await pauseTimer() }
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
            
        case (.breakPrompt, .complete),
            (.mindfulness, .complete),
            (.breakPrompt, .inProgress),
            (.mindfulness, .inProgress),
            (.social, .inProgress),
            (.completion, .inProgress):
            break
            
        case (_, .cancel):
            currentModal = nil
        }
    }
        
}

