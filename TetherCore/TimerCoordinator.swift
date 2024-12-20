//
//  TimerCoordinator.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import Foundation
import SwiftUI

//[Protocol][Conformance StorageManaging][Storage][-> Void]
@MainActor
class TimerCoordinator: ObservableObject {
    @Published private(set) var betterNameTimer: any TimeProtocol
    @Published private(set) var isRunning = false
    @Published private(set) var progress: Float = 0.0
    @Published private(set) var secs: Int
    @Published var showClock = false
    
    /// How to receive updates from tetherCoordinator, coreVM
    private let tetherCoordinator: TetherCoordinator
    private let coreVM: CoreViewModel
    private var timeAsTask: Task<Void, Never>?
    
    static func create(
        tetherCoordinator: TetherCoordinator,
        coreVM: CoreViewModel,
        clockType: CountdownTypes = .production
    ) async -> TimerCoordinator {
        let timer = TimerFactory.makeTimePiece(clockType)
        let initialSeconds = await timer.totalSeconds
        
        return await TimerCoordinator(
            timer: timer,
            seconds: initialSeconds,
            tetherCoordinator: tetherCoordinator,
            coreVM: coreVM
        )
    }
    
    private init(
        timer: any TimeProtocol,
        seconds: Int,
        tetherCoordinator: TetherCoordinator,
        coreVM: CoreViewModel
    ) async {
        self.betterNameTimer = timer
        self.secs = seconds
        self.tetherCoordinator = tetherCoordinator
        self.coreVM = coreVM
    }
    
    ///Helper method to get a coordinator-less instance
//    static func makeStandalone() async -> TimerCoordinator {
//        await TimerCoordinator(tetherCoordinator: TetherCoordinator())
//    }
    
/// "Timer Management"
    func startClock() {   /// [Function][Timer][CoreVM][-> Void]
        Task {
            for await update in await betterNameTimer.start() {
                self.secs = update.seconds
                self.progress = update.progress
                self.isRunning = true
                
                if update.seconds == 0 {
                    await onZeroHapticAction()
                }
            }
        }
    }
//    await MainActor.run {
//        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//            showClock = true
//        }
//    }

    func resetToStartAfterLeaving() { /// [Function][Timer][CoreVM][->Void]
//        countDownAmt = 1200
//        Task {
//            await startClock()
//            tetherCoordinator.showClock(true)
//        }
    }
    func pauseTimer() async {    /// [Function][Timer][CoreVM][-> Void]
        await betterNameTimer.pause()
        isRunning = false
        showClock = false
    }
    
    func stopClock() async {
        await betterNameTimer.stop()
        isRunning = false
        showClock = false
        secs = await betterNameTimer.totalSeconds
    }
    
    
    
    ///         CLOCK STATE MANAGEMENT
    func switchTheClock(_ type: CountdownTypes) async {
        await betterNameTimer.stop()
        betterNameTimer = TimerFactory.makeTimePiece(type)
        secs = await betterNameTimer.totalSeconds
        showClock = true
    }
     
///// When Timer is Complete!
    func onZeroHapticAction() async {
        /// Haptics notify user, on main thread
        HapticStyle.medium.trigger()
        isRunning = false
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showClock = false
        }
        
        /// Handle state transition
        if case .secondTether(let coil) = coreVM.currentState {
            if !coil.tether1.isCompleted {
                await tetherCoordinator.navigate(to: .tether1Modal)
            } else if !coil.tether2.isCompleted {
                await tetherCoordinator.navigate(to: .tether2Modal)
            }
        }
    }
///Clearing State and UI
    func stopsCountdownClearsState() async {
        ///Use CountdownActor to stop timer completely
        Task {
            await betterNameTimer.stop()
            isRunning = false
            showClock = false
            secs = await betterNameTimer.totalSeconds
        }
    }
    
    func resumeUserTimerFlow() async {
        Task {
            await switchTheClock(.production)
            await startClock()
            tetherCoordinator.currentModal = nil        ///Dismisses here, rather than in CoreView or ModalView
        }
    }

}