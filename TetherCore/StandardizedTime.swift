//
//  StandardizedTime.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/18/24.
//

import Foundation

protocol StandardizedTime: Actor {
    var isRunning: Bool { get set }
    var progress: Float { get set }
    var secondsRemaining: Int { get set }
    var totalSeconds: Int { get }
    var task: Task<Void, Never>? { get set }
    
    func start() async -> AsyncStream<(seconds: Int, progress: Float)>
    func pause() async
    func stop() async
    func formatTimeRemaining(_ seconds: Int) -> String
    
}
struct TimerUpdate {
    let seconds: Int
    let progress: Float
}

/// Default implementations for common timer/countdown logic
extension StandardizedTime {
    func start() async -> AsyncStream<TimerUpdate> {
        /// Cancel/clean up any existing timer
        ///  then creates and returns a new stream
        await cancelExistingTask()
        // Initialize timer state
        isRunning = true
        secondsRemaining = totalSeconds
        progress = 1.0
    
        return AsyncStream { continuation  in
            task = Task {
                ///Timer loop
                while !Task.isCancelled && isRunning && secondsRemaining > 0 {
                    do {
                        try await Task.sleep(for: .nanoseconds(1_000_000_000))  /// 1 second
                        guard !Task.isCancelled && isRunning else { break }
                        
                        ///Update state
                        secondsRemaining -= 1
                        progress = Float(secondsRemaining) / Float(totalSeconds)
                        ///Yield update
                        let update = TimerUpdate(
                            seconds: secondsRemaining,
                            progress: progress
                        )
                        continuation.yield((update))
                        
                    } catch {
                        break
                    }
                    
                    if secondsRemaining == 0 {
                        isRunning = false
                    }
                    continuation.finish()
                }
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


/// Timer factory for dependency injection
enum TimerFactory {
    static func makeTimer(_ type: CountdownTypes) -> any TimerProtocol {
        switch type {
        case .production: return CountdownActor()
        case .six: return Countdown6Actor()
        case .mind: return CountdownMindfulActor()
        }
    }
}
