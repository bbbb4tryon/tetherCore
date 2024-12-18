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
    
    @EnvironmentObject var coordinator: TetherCoordinator
    @Published var currentTetherText: String = ""
    @Published private(set) var currentState: TetherState = .empty
    @Published private(set) var progress: Float = 0.0
    @Published private(set) var countDownAmt: Int = 1200     /// 20 minutes
    @Published var showClock: Bool = false
    @Published private(set) var error: GlobalError?

    private let storage: TetherStorageManager
    
    private let mainTimer: CountdownActor
    private let progressActor = ProgressActor()
    
    
    ///DELETE NOW?
//    @Published var currentModal: ModalType?
    
//    testing: Bool = false; @Published var isTesting: Bool = false;  self.isTesting = testing  /// Track testing state; if testing {
//        setupTestData()
//    }
    
    /// Necessary - keeps initialization of actors and dependencies
    init(
        coordinator: TetherCoordinator,
         storage: TetherStorageManager = TetherStorageManager()
    ){
        self.mainTimer = CountdownActor()   ///Initialize timer actor
        self.storage = storage          /// Initialize storage
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
    func submitTether() async throws {
        guard !currentTetherText.isEmpty else { return }
        let newTether = Tether(tetherText: currentTetherText)
        
        switch currentState {
        case .empty:
            currentState = .firstTether(newTether)
            
        case .firstTether(let firstTether):
            let coil = Coil(tether1: firstTether, tether2: newTether)
            currentState = .secondTether(coil)
            
            try await storage.saveCoil(coil)
            await mainTimer.start()
            await coordinator.navigate(to: .tether1Modal)
        /// Already have both tethers, ignore additional submissions
        case .secondTether, .completed:
            break
        }
        currentTetherText = ""
    }
    
/////////////////////////////////////// DELETE
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
    func handleModalAction(for type: ModalType, action: ModalAction) async throws {
        switch (type, action) {
        case (.tether1, .complete):
            if case .secondTether(var coil) = currentState {
                coil.tether1.isCompleted = true
                currentState = .secondTether(coil)
                await coordinator.navigate(to: .tether2Modal)
            }
            
        case (.tether2, .complete):
            if case .secondTether(var coil) = currentState {
//          guard let !coordinator.navigate(to: .tether1Modal) else { return }
                coil.tether2.isCompleted = true
                currentState = .completed(coil)
                await progressActor.updateProgress(progress)       //Starts when tapped
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
        case (.tether1, .inProgress), (.tether2, .inProgress):
            Task {
                await pause()
                reset()
                await progressActor.updateProgress(progress)
            }
            coordinator.dismissModal()

            /// Cancel
        case (.completion, .cancel):
            /// Skip Social, go home
            if case .completed(let coil) = currentState {
                Task {
                    try? await storage.moveCoilToCompleted(coil)
                    reset()
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
//        self.showClock = true
//        self.currentModal = .tether1
//    }
