//
//  CoreVM.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import Foundation
import SwiftUI

// MARK: - CoreViewModel
@MainActor
class CoreViewModel: ObservableObject { ///State Managment confined to main thread; good
    
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
        
        var needsRestoration: Bool {
            switch self {
            case .empty: return false
            case .firstTether: return true
            case .secondTether(let coil): return !coil.tether1.isCompleted || !coil.tether2.isCompleted
            case .completed: return false
            }
        }
    }
    
    /// Types of the limits (at correctly stated at the 'type level'
    private enum Constants {
        static let inputLimit = 160
    }
    
//    @EnvironmentObject var coordinator: TetherCoordinator
    @Published private(set) var error: GlobalError?
    @Published var currentTetherText: String = ""
    @Published var showClock: Bool = false
    @Published private(set) var currentState: TetherState = .empty
    @Published private(set) var progress: Float = 0.0
    @Published private(set) var countDownAmt: Int = 1200     /// 20 minutes
    @Published private(set) var inputLimit = Constants.inputLimit

    private let tetherCoordinator: TetherCoordinator
    private let storage: StorageManager
    private let baseClock: any TimeProtocol
    private var timerCoordinator: TimerCoordinator?         /// Optional; is VAR now because of this
    
    
    ///DELETE NOW?
//    @Published var currentModal: ModalType?
    
//    testing: Bool = false; @Published var isTesting: Bool = false;  self.isTesting = testing  /// Track testing state; if testing {
//        setupTestData()
//    }
    
    /// Necessary - keeps initialization of actors and dependencies
    init(
        clockType: CountdownTypes,
        tetherCoordinator: TetherCoordinator,
        storage: StorageManager = StorageManager()
    ){
        self.baseClock = TimerFactory.makeTimePiece(clockType)
        self.tetherCoordinator = tetherCoordinator
        self.storage = storage                              /// Initialize storage
        self.timerCoordinator = nil                         /// Explicitly nil because its optional, should flip its switch
    }
    /// Method sets the coordinator later
    func setTimerCoordinator(_ coordinator: TimerCoordinator) {
        self.timerCoordinator = coordinator
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
    /// Flow of tethers/input -BUSINESS Logic Layer
    func submitTether() async throws {
        ///Generates error; validates input
        guard !currentTetherText.isEmpty else { throw StateTransitionError.invalidStateChange }
        let newTether = Tether(tetherText: currentTetherText)
        
        switch currentState {
        case .empty:
            currentState = .firstTether(newTether)
    
        case .firstTether(let firstTether):
            let coil = Coil(tether1: firstTether, tether2: newTether)
            currentState = .secondTether(coil)
            do {
                try? await storage.saveCoil(coil)
                try await baseClock.start()
                tetherCoordinator.navigate(to: .tether1Modal)
        } catch {
            self.error = CoreVMError.storageFailure
        }
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
    func validateInput() throws {
        if currentTetherText.isEmpty {
            throw InputValidationError.emptyText
        }
        if currentTetherText.count > inputLimit {
            throw InputValidationError.invalidLength
        }
        ///State-specific validation handled here
        if case .empty = currentState, currentTetherText.count > inputLimit {
            throw CoreVMError.storageFailure
        }
    }
            
    //MARK: Modal Actions Management
    func handleModalAction(for type: ModalType, action: ModalAction) async throws {
        switch (type, action) {
        case (.returningUser, .inProgress):
            if case .firstTether(let firstTether) = currentState {
               if !firstTether.isCompleted {
                    currentState = .firstTether(firstTether)
               } else {
                   currentState = .secondTether(Coil(tether1: firstTether, tether2: Tether(tetherText: "")))
               }
            }
            
        case (.tether1, .complete):
            if case .secondTether(var coil) = currentState {
                coil.tether1.isCompleted = true
                currentState = .secondTether(coil)
                tetherCoordinator.navigate(to: .tether2Modal)
            }
            
        case (.tether2, .complete):
            if case .secondTether(var coil) = currentState {
//          guard let !tetherCoordinator.navigate(to: .tether1Modal) else { return }
                coil.tether2.isCompleted = true
                currentState = .completed(coil)
                timerCoordinator?.showClock = true   //Starts when tapped
                tetherCoordinator.navigate(to: .completionModal)
            }
 
        case (.completion, .complete):
            /// Social sharing flow
            if case .completed(let coil) = currentState {
                Task {
                    try? await storage.moveCoilToCompleted(coil)
                    tetherCoordinator.navigate(to: .socialModal)
                }
            }
            
        case (.social, .complete):
            /// Finish flow; Handle social post completion
            Task {
                await baseClock.stop()
                currentState = .empty
                tetherCoordinator.navigate(to: .home)
            }
            
            /// In Progress
        case (.tether1, .inProgress), (.tether2, .inProgress):
            Task {
                await timerCoordinator?.pauseTimer()
                tetherCoordinator.reset()
                timerCoordinator?.showClock = true
            }
            tetherCoordinator.dismissModal()

            /// Cancel
        case (.completion, .cancel):
            /// Skip Social, go home
            if case .completed(let coil) = currentState {
                Task {
                    try? await storage.moveCoilToCompleted(coil)
                    tetherCoordinator.reset()
                }
            }
 
        case (.breakPrompt, .complete),
            (.mindfulness, .complete),
            (.breakPrompt, .inProgress),
            (.mindfulness, .inProgress),
            (.social, .inProgress),
            (.completion, .inProgress):
            break
            
            ///Wildcard case - matches any ModalType when action is .cancel
        case (_, .cancel):
            tetherCoordinator.dismissModal()
            
            /// Note: resumeUserTimerFlow() already handles returningUser completion
        case (.returningUser, .complete):
            try await timerCoordinator?.resumeUserTimerFlow()
        }
    }
    
    ///Clear All Modals and Text
    func clearEverythingFromUI() async {
        
        /// Clear clock
        await timerCoordinator?.stopsCountdownClearsState()
        
        /// Clear view state, text
        currentState = .empty
        currentTetherText = ""
        /// Clear navigation/modals
        tetherCoordinator.dismissModal()
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
