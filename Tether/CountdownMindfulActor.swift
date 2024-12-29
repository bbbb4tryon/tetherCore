//
//  CountdownMindfulActor.swift
//  Tether
//
//  Created by Benjamin Tryon on 12/8/24.
//

import Foundation

actor CountdownMindfulActor: TimeProtocol {
    var task: Task<Void, Never>?
    var isRunning = false
    var secondsRemaining: Int
    var progress: Float = 1.0
    let totalSeconds = 180
    
    nonisolated let id = UUID()
    init() {
        secondsRemaining = totalSeconds
    }
    ///Better for reusability w Mindfulness timer
    func start() async -> AsyncStream<(seconds: Int, progress: Float)> {
        /// Cancel any existing task
        await cancelExistingTask()
        
        isRunning = true
        secondsRemaining = totalSeconds
        progress = 1.0
        
        return AsyncStream { continuation  in
            task = Task {
                while !Task.isCancelled && isRunning && secondsRemaining > 0 {
                    do {
                        try await Task.sleep(for: .nanoseconds(1_000_000_000))  /// 1 second
                        guard !Task.isCancelled && isRunning else { break }
                        
                        secondsRemaining -= 1
                        progress = Float(secondsRemaining) / Float(totalSeconds)
                        continuation.yield((secondsRemaining, progress))
                        
                    } catch {
                        break
                    }
                }
                
                if secondsRemaining == 0 {
                    isRunning = false
                }
                continuation.finish()
            }
        }
    }
}

