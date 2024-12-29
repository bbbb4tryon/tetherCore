//
//  CountdownTypes.swift
//  Tether
//
//  Created by Benjamin Tryon on 12/16/24.
//
//
import SwiftUI


enum CountdownTypes {   /// Don't add throws or initalizations - screws up TimerCoordinator
    case production     /// 20 minutes
    case six            /// 6 seconds
    case mind           /// 3 minutes
    
    var countdown: any TimeProtocol {
        switch self {
        case .production: return CountdownActor()
        case .six: return Countdown6Actor()
        case .mind: return CountdownMindfulActor()
        }
    }
}
