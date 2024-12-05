//
//  CoreVM.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import Foundation

// MARK: - CoreViewModel
/// CoreViewModel
/// 
@MainActor
class CoreViewModel: ObservableObject {
    @Published private(set) var error: GlobalError?
    @Published var currentTetherText: String = ""
    @Published var currentCoil: Coil?
    
    @Published var currentModal: ModalType?
    
    private let storage: TetherStorageManager
    init(storage: TetherStorageManager = TetherStorageManager()){
        self.storage = storage
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

