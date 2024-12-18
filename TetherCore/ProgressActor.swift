//
//  ProgressActor.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/16/24.
//

import Foundation

/// Track Progress value
actor ProgressActor {
    private(set) var progress: Float = 0.0
    
    func updateProgress(_ newProgress: Float) {
        progress = newProgress
    }
    func reset() {
        progress = 0.0
    }
}
