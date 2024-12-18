//
//  StorageManager.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import Foundation

//[Protocol][Conformance StorageManaging][Storage][-> Void]
actor TimeManager {
/// "Timer Management"
func startTimer() async {   /// [Function][Timer][CoreVM][-> Void]
    await mainTimer.start {
        Task {
            self.countDownAmt -= 1
            if self.countDownAmt == 0 {
                self.onZero()
            }
            ///Update progress actor
            await self.progressActor.updateProgress(Float(self.countDownAmt) / 1200.0)
        }
    }
    await MainActor.run {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showClock = true
        }
    }
}
private func resetAndStartTimer() { /// [Function][Timer][CoreVM][->Void]
    countDownAmt = 1200
    Task {
            await startTimer()
            coordinator.showClock(true)
        }
    }
private func pauseTimer() async {    /// [Function][Timer][CoreVM][-> Void]
    await mainTimer.pause()
    showClock = false
}
private func handleTimerDisplay() async {
    //
}
/// When Timer is Complete!
func onZero() {
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
func resetState() {
    ///Use CountdownActor to stop timer completely
    Task {
        await mainTimer.stop()
        currentState = .empty
        coordinator.reset()     ///Modal/UI reset
        ///
    }
}
    //
}
