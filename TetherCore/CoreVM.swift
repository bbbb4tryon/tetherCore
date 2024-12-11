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
    
    enum TetherState: Equatable {
        case empty                  /// Nothing entered
        case firstTether(Tether)    /// First Tether entered
        case secondTether(Coil)     /// Both tethers in coil, not completed
        case completed(Coil)        /// Coil with completion status
        
        ///Helper computed properties
        var hasFirstTether: Bool {
            switch self {
            case .empty: return false
            default: return true
            }
        }
        var currentCoil: Coil? {
            switch self {
            case .secondTether(let coil), .completed(let coil):
                return coil
            default: return nil
            }
        }
        ///Input placeholder texts
        var inputPlaceholder: String {
            switch self {
            case .empty: return "Required"
            case .firstTether: return "Enter One More"
            default: return ""
            }
        }
    }
    
    @Published private(set) var currentState: TetherState = .empty
    @Published private(set) var timerSeconds: Int = 1200     /// 20 minutes
    @Published var currentTetherText: String = ""
    @Published var showTimer: Bool = false
    @Published private(set) var error: GlobalError?
    
    private let mainTimer: TimerActor
    private let coordinator: TetherCoordinator  /// [Property][Actor][CoreVM][-> Timer]
    private let storage: TetherStorageManager
    
    
    ///DELETE NOW?
//    @Published var currentModal: ModalType?
    
//    testing: Bool = false; @Published var isTesting: Bool = false;  self.isTesting = testing  /// Track testing state; if testing {
//        setupTestData()
//    }
    
    init(
        coordinator: TetherCoordinator = TetherCoordinator(),
         storage: TetherStorageManager = TetherStorageManager()
    ){
        self.mainTimer = TimerActor()   ///Initialize timer actor
        self.storage = storage          /// Initialize storage
        self.coordinator = coordinator  /// Initialize coordinator
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
                coordinator.navigate(to: .tether1Modal)
            }
        /// Already have both tethers, ignore additional submissions
        case .secondTether, .completed:
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
        Task {
                await startTimer()
                coordinator.showTimer(true)
            }
        }
    
    private func pauseTimer() async {    /// [Function][Timer][CoreVM][-> Void]
        await mainTimer.pause()
        showTimer = false
    }
        /// When Timer is Complete!
    func onTimerComplete() {
        /// Haptics notify user
        HapticStyle.medium.trigger()
        switch currentState {
        case .secondTether(let coil):
            if !coil.tether1.isCompleted {
                coordinator.navigate(to: .tether1Modal)
            } else if !coil.tether2.isCompleted {
                coordinator.navigate(to: .tether2Modal)
            }
        default:
            break
        }
    }
    /// State and UI
    func resetAll() {
        ///Use TimerActor to stop timer completely
        Task {
            await mainTimer.stop()
            currentState = .empty
            coordinator.reset()     ///Modal/UI reset
            ///
        }
    }
       
    ///BEFORE:
    ///     if let coil = currentCoil {
    /* if !coil.tether1.isCompleted {
        currentModal = .tether1
    } else if !coil.tether2.isCompleted {
        currentModal = .tether2
    }
     */
    
    // MARK: - Error Management
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
    
    //MARK: Modal Actions Management
    func handleModalAction(for type: ModalType, action: ModalAction) {
        switch (type, action) {
        case (.tether1, .complete):
            if case .secondTether(var coil) = currentState {
                coil.tether1.isCompleted = true
                currentState = .secondTether(coil)
                coordinator.navigate(to: .tether2Modal)
            }
            
        case (.tether2, .complete):
            if case .secondTether(var coil) = currentState {
//                guard let !coordinator.navigate(to: .tether1Modal) else { return }
                coil.tether2.isCompleted = true
                currentState = .completed(coil)
                coordinator.navigate(to: .completionModal)
            }
 
        case (.completion, .complete):
            /// Social sharing flow
            if case .completed(let coil) = currentState {
                Task {
                    try? await storage.moveCoilToCompleted(coil)
                    coordinator.navigate(to: .socialModal)
                }
            }
            
        case (.social, .complete):
            /// Finish flow; Handle social post completion
            Task {
                await mainTimer.stop()
                currentState = .empty
                coordinator.navigate(to: .home)
            }
            
            /// In Progress
        case (.tether1, .inProgress):
            Task {
                await pauseTimer()
                resetAndStartTimer()
            }
            coordinator.dismissModal()
            
        case (.tether2, .inProgress):
            Task {
                await pauseTimer()
                resetAndStartTimer()
            }
            coordinator.dismissModal()
            
            /// Cancel
        case (.completion, .cancel):
            /// Skip Social, go home
            if case .completed(let coil) = currentState {
                Task {
                    try? await storage.moveCoilToCompleted(coil)
                    resetAll()
                }
            }
 
        case (.breakPrompt, .complete),
            (.mindfulness, .complete),
            (.breakPrompt, .inProgress),
            (.mindfulness, .inProgress),
            (.social, .inProgress),
            (.completion, .inProgress):
            break
            
        case (_, .cancel):
            coordinator.dismissModal()
        }
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
