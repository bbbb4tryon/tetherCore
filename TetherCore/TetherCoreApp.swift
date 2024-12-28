//
//  TetherCoreApp.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 11/28/24.
//

import Foundation
import SwiftUI
import UIKit

@main
struct TetherCoreApp: App {
    @StateObject private var tetherCoordinator = TetherCoordinator()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(tetherCoordinator)
        }
    }
}
