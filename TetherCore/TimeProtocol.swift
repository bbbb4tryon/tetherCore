//
//  StandardizedTime.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/18/24.
//

import Foundation

protocol TimeProtocol: Actor {
    var isRunning: Bool { get set }
    var secondsRemaining: Int { get set }
    var totalSeconds: Int { get }
    var task: Task<Void, Never>? { get set }
    
    func start() async -> AsyncStream<(seconds: Int, progress: Float)>
    func pause() async
    func stop() async
    
}

struct TimerUpdate {
    let seconds: Int
    let tickProgress: Float
}

/// Default implementations for common timer/countdown logic
extension TimeProtocol {
    func start() async -> AsyncStream<TimerUpdate> {
        /// Cancel/clean up any existing timer
        ///  then creates and returns a new stream
        await cancelExistingTask()
        // Initialize timer state
        isRunning = true
        secondsRemaining = totalSeconds
//        progress = 1.0
    
        return AsyncStream { continuation  in
            task = Task {
                ///Timer loop
                while !Task.isCancelled && isRunning && secondsRemaining > 0 {
                    do {
                        try await Task.sleep(for: .nanoseconds(1_000_000_000))  /// 1 second
                        guard !Task.isCancelled && isRunning else { break }
                        
                        ///Update state
                        secondsRemaining -= 1
                        let tickProgress = Float(secondsRemaining) / Float(totalSeconds)
                        ///Yield update
                        let update = TimerUpdate(
                            seconds: secondsRemaining,
                            tickProgress: tickProgress
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
    
    internal func cancelExistingTask() async {
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
    }
    
    nonisolated func formatTimeRemaining( _ seconds: Int) -> String {
        let minutes = seconds / 60
        return String(format: "%02d", minutes)
    }
}


/// Timer factory for dependency injection
enum TimerFactory {
    static func makeTimePiece(_ type: CountdownTypes) -> any TimeProtocol {
        switch type {
        case .production: return CountdownActor()
        case .six: return Countdown6Actor()
        case .mind: return CoundownMindfulActor()
        }
    }
}
