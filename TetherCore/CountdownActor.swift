//
//  CountdownActor.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/8/24.
//

import Foundation

actor CountdownActor: StandardizedTime {
    private var task: Task<Void, Never>?
    private(set) var isRunning = false
    private(set) var secondsRemaining: Int
    private(set) var progress: Float = 1.0
    private let totalSeconds = 1200
    
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
    
    private func cancelExistingTask() async {
        task?.cancel()      ///Signals task to stop
        task = nil          /// Waits for actor isolation before nullifying -> cancelExistingTask() in stop() synchronizes changes and cleanup
    }
    
    func pause() async {
        isRunning = false
        await cancelExistingTask()
    }
    
    func stop() async {
        isRunning = false
        await cancelExistingTask()      /// Ensures synchronized cleanup
        secondsRemaining = totalSeconds
        progress = 1.0
    }
    
    nonisolated func formatTimeRemaining( _ seconds: Int) -> String {
        let minutes = seconds / 60
        return String(format: "%02d", minutes)
    }
}

