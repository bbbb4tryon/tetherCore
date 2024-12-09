//
//  TimerActor.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/8/24.
//

import Foundation

/// TimerActor
///     start - ticking
/// stop, pause
actor TimerActor {
    private var task: Task<Void, Never>?
    private(set) var isRunning = false
    
    ///Better for reusability w Mindfulness timer
    func start(onTick: @escaping () ->Void) {
        isRunning = true
        task?.cancel()
        task = Task {
            while !Task.isCancelled && isRunning {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled {
                    onTick()
                }
            }
        }
    }
    
    func pause() {
        isRunning = false
        task?.cancel()
    }
    
    func stop() {
        isRunning = false
        task?.cancel()
        task = nil
    }
}

