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
    
    func start() async throws -> AsyncStream<(seconds: Int, progress: Float)>
    func pause() async throws
    func stop() async throws
    
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
        do {
            /// Cancel/clean up any existing timer
            ///  then creates and returns a new stream
            await cancelExistingTask()
            /// Initialize timer state
            isRunning = true
            secondsRemaining = totalSeconds
            //        progress = 1.0
            
            return createTimerStream()
            } catch {
            throw TimerError.invalidStateTransition
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
