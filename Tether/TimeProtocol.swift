//
//  StandardizedTime.swift
//  Tether
//
//  Created by Benjamin Tryon on 12/18/24.
//

import Foundation

protocol TimeProtocol: Actor {
    var isRunning: Bool { get set }
    var secondsRemaining: Int { get set }
    var totalSeconds: Int { get }
    var task: Task<Void, Never>? { get set }
    
    /// Only start() needs throws b/c potential Task cancellation
    func start() async throws -> AsyncStream<(seconds: Int, progress: Float)>
    func pause() async
    func stop() async
    
}

struct TimerUpdate {
    let seconds: Int
    let progress: Float
    
    var asTuple: (seconds: Int, progress: Float) {
        return (seconds: seconds, progress: progress)
    }
}

/// Default implementations for common timer/countdown logic
extension TimeProtocol {
    /// Helper function to manage timer updates
    ///   Needs do-catch b/c Task.sleep
    func createTimerStream() -> AsyncStream<(seconds: Int, progress: Float)> {
        AsyncStream { continuation  in
            task = Task<Void, Never> {      /// Task defined to non-throw
                ///Timer loop
                while !Task.isCancelled && isRunning && secondsRemaining > 0 {
                    do {
                        try await Task.sleep(for: .nanoseconds(1_000_000_000))  /// 1 second
                        guard !Task.isCancelled && isRunning else { break }
                        
                        ///Update state
                        secondsRemaining -= 1
                        let tickProgress = Float(secondsRemaining) / Float(totalSeconds)
                        ///Yield update
                        let update = TimerUpdate(seconds: secondsRemaining, progress: tickProgress)
                        continuation.yield(update.asTuple)
                    } catch {
                        isRunning = false
                        break
                    }
                }
                if secondsRemaining == 0 { isRunning = false }
                continuation.finish()
            }
        }
    }
    
    func start() async throws -> AsyncStream<(seconds: Int, progress: Float)> {
        /// No try-catch b/c Task.sleep is only throw
        /// Cancel/clean up any existing timer
        ///  then creates and returns a new stream
        await cancelExistingTask()
        /// Initialize timer state
        isRunning = true
        secondsRemaining = totalSeconds
        //        progress = 1.0
        
        return createTimerStream()
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
        case .mind: return CountdownMindfulActor()
        }
    }
}
