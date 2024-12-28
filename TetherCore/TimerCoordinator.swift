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
    
    /// State persistence keys
    private let timerStateKey = "timer_state"
    private let secondsKey = "seconds_remaining"
    
    static func create(
        tetherCoordinator: TetherCoordinator,
        coreVM: CoreViewModel,
        clockType: CountdownTypes = .production
    ) async -> TimerCoordinator {
        /// Factory call; can't fail (exhaustive enum; each case returns a concrete type implementing TimeProtocol; all return values are actor instantiations)
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
    func startClock() async throws {   /// Task cancellation, but simplified error handling
        guard !Task.isCancelled else { return }
        for await update in try await betterNameTimer.start() {
            if Task.isCancelled { break }
            
            self.secs = update.seconds
            self.progress = update.progress
            self.isRunning = true
            
            if update.seconds == 0 {
                await onZeroHapticAction()
            }
        }
    }
    
    //    await MainActor.run {
    //        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
    //            showClock = true
    //        }
    //    }
    
    
    func pauseTimer() async {    /// No throws needed - pause can't fail
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
        /// Stop() does not throw, no need for do-try-catch
        ///   TimerFactory can't fail (enum)
        await betterNameTimer.stop()
        betterNameTimer = TimerFactory.makeTimePiece(type)
        secs = await betterNameTimer.totalSeconds
        showClock = true
    }
    
    ///When Timer is Complete!
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
                tetherCoordinator.navigate(to: .tether1Modal)
            } else if !coil.tether2.isCompleted {
                tetherCoordinator.navigate(to: .tether2Modal)
            }
        }
    }
    ///Clearing State and UI
    func stopsCountdownClearsState() async {
        ///Use CountdownActor to stop timer completely
        await betterNameTimer.stop()
        isRunning = false
        showClock = false
        secs = await betterNameTimer.totalSeconds
    }
    
    func resumeUserTimerFlow() async throws {
        do {
            await switchTheClock(.production)
            try await startClock()
            tetherCoordinator.currentModal = nil        ///Dismisses here, rather than in CoreView or ModalView
            await saveTimerState()                      ///Saves state AFTER successful resume
        } catch {
            ///Reset to save state
            isRunning = false
            showClock = false
            tetherCoordinator.currentModal = nil
            UserDefaults.standard.removeObject(forKey: timerStateKey)
        }
    }
    
    /// ScenePhase handling
    func handleSceneTransition(_ phase: ScenePhase) async {
        switch phase {
        case .active:
            await restoreTimerState()
        case .inactive:
            await pauseTimer()
        case .background:
            await saveTimerState()
        @unknown default:
            break
        }
    }
    
    private func saveTimerState() async {
        let state = TimerState(
            isRunning: isRunning,
            remainingSeconds: secs,
            showClock: showClock
        )
        
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: timerStateKey)
        }
        
        await betterNameTimer.pause()
    }
    
    private func restoreTimerState() async {
        guard let data = UserDefaults.standard.data(forKey: timerStateKey),
              let state = try? JSONDecoder().decode(TimerState.self, from: data) else {
            return
        }
        
        if state.isRunning {
            await switchTheClock(.production)
            try? await startClock()
        }
        
        self.secs = state.remainingSeconds
        self.showClock = state.showClock
    }
    
    // Timer state struct
    private struct TimerState: Codable {
        let isRunning: Bool
        let remainingSeconds: Int
        let showClock: Bool
    }
}
