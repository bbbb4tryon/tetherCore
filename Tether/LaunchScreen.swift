//
//  LaunchScreen.swift
//  Tether
//
//  Created by Benjamin Tryon on 12/28/24.
//
//
//import SwiftUI
//
//struct LaunchScreen: View {
//    @Environment(\.scenePhase) private var scenePhase
//    @EnvironmentObject var tetherCoordinator: TetherCoordinator
//    @StateObject private var coordinator: LaunchCoordinator
//    @State private var showHintTooltip = false
//    @State private var hintPosition = CGPoint(x: 0, y: 0)   /// For positioning
//    
//    init() {
//        // Initialize with injected TetherCoordinator
//        let tetherCoordinator = TetherCoordinator()
//        _coordinator = StateObject(wrappedValue: LaunchCoordinator(tetherCoordinator: tetherCoordinator))
//    }
//    var body: some View {
//            ZStack {
//                if coordinator.hasCompletedLaunch {
//                    MainTabView()
//                        .overlay(alignment: .bottomTrailing) {
//                            if coordinator.showHintIndicator {
//                                HintButton(showTooltip: $showHintTooltip)
//                                    .padding()
//                            }
//                        }
//                        .onChange(of: showHintTooltip) { oldValue, newValue in
//                            if newValue {
//                                Task { @MainActor in
//                                    HapticStyle.gentle.trigger()
//                                }
//                            }
//                        }
//                } else {
//                    // Launch animation
//                    VStack {
//                        Image(systemName: "arrow.triangle.2.circlepath")
//                            .font(.system(size: 60))
//                            .foregroundColor(.theme.primaryBlue)
//                            .rotationEffect(.degrees(coordinator.hasCompletedLaunch ? 360 : 0))
//                            .animation(
//                                .spring(response: 0.6, dampingFraction: 0.5),
//                                value: coordinator.hasCompletedLaunch
//                            )
//                        
//                        Text("Tether")
//                            .font(.title.bold())
//                            .foregroundColor(.theme.primaryBlue)
//                    }
//                }
//            }
//            .task {
//                await coordinator.handleAppLaunch()
//            }
//            .onChange(of: scenePhase) { _, newPhase in
//                Task {
//                    await coordinator.handleSceneChange(newPhase)
//                }
//            }
//            .alert("Welcome to Tether", isPresented: $coordinator.permissions) {
//                Button("Get Started", role: .cancel) {
//                    Task { @MainActor in
//                        HapticStyle.gentle.trigger()
//                    }
//                }
//            } message: {
//                Text("Tether helps maintain your focus sessions.")
//            }
//            .environmentObject(tetherCoordinator)
//        }
//    }
