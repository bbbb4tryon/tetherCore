//
//  LaunchCoordinator.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/28/24.
//

import SwiftUI

@MainActor
final class LaunchCoordinator: ObservableObject {
    @Published private(set) var hasCompletedLaunch = false
    @Published private(set) var isFirstLaunch = false
    @Published private(set) var showHintIndicator = false
    
    @AppStorage("deviceID") private var deviceID = UIDevice.current.identifierForVendor?.uuidString
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    
    private let tetherCoordinator: TetherCoordinator
    private var timerCoordinator: TimerCoordinator?
    
    init(tetherCoordinator: TetherCoordinator) {
        self.tetherCoordinator = tetherCoordinator
        self.isFirstLaunch = !hasLaunchedBefore
    }
    
    func handleAppLaunch() async {
        // Quick haptic feedback for launch
        await MainActor.run {
            HapticStyle.gentle.trigger()
        }
        
        // Initialize TimerCoordinator through TetherCoordinator
        if timerCoordinator == nil {
            let coordinator = await TimerCoordinator.create(
                tetherCoordinator: tetherCoordinator,
                coreVM: CoreViewModel(
                    clockType: .production,
                    tetherCoordinator: tetherCoordinator
                )
            )
            tetherCoordinator.setTimerCoordinator(coordinator)
            self.timerCoordinator = coordinator
        }
        
        // Show launch animation briefly
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        if isFirstLaunch {
            showPermissionsRequest = true
            await initializeFirstLaunch()
            hasLaunchedBefore = true
            showHintIndicator = true
        }
        
        hasCompletedLaunch = true
    }
    
    private func initializeFirstLaunch() async {
        // Let TetherCoordinator handle the scene phase for background state
        await tetherCoordinator.handleScenePhase(.active)
        
        // Ensure timer coordinator is ready for background operations
        if let timerCoordinator {
            await timerCoordinator.handleSceneTransition(.active)
        }
    }
    
    func handleSceneChange(_ phase: ScenePhase) async {
        await tetherCoordinator.handleScenePhase(phase)
    }
}

