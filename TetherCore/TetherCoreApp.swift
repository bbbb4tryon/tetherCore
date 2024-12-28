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
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var tetherCoordinator = TetherCoordinator()
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @State private var showWelcomeAlert = false
    @State private var showHintTooltip = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                //                    .environmentObject(tetherCoordinator)
                    .overlay(alignment: .bottomTrailing) {
                        if !hasLaunchedBefore {
                            HintButton(showTooltip: $showHintTooltip)
                                .padding()
                        }
                    }
                    .onChange(of: scenePhase) { _, newPhase in
                        Task { @MainActor in
                            ///Creates a clean delegation into existing concurrent implementation
                            ///  Maintain actor isolation
                            ///-> Calls TetherCoordinator extension method which internally handles TimerCoordinator
                            /// Coordinates scene changes through proper hierarchy: TetherCoreApp -> TetherCoordinator -> TimerCoordinator
                            await tetherCoordinator.handleScenePhase(newPhase)
                        }
                    }
            }
            .environmentObject(tetherCoordinator)
            .task {
                if !hasLaunchedBefore {
                    // Initial launch haptic
                    await MainActor.run {
                        HapticStyle.gentle.trigger()
                    }
                    showWelcomeAlert = true
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                Task { @MainActor in
                    await tetherCoordinator.handleScenePhase(newPhase)
                }
            }.alert("Welcome to TetherCore", isPresented: $showWelcomeAlert) {
                Button("Get Started", role: .cancel) {
                    Task { @MainActor in
                        HapticStyle.gentle.trigger()
                        hasLaunchedBefore = true
                    }
                }
            } message: {
                Text("TetherCore helps maintain your focus sessions.")
            }
        }
    }
}
