//
//  ModalView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/5/24.
//

import SwiftUI

struct ModalView: View {
    @EnvironmentObject var coordinator: TetherCoordinator      // No = or (), it is not initialized here and don't want it to be
    @ObservedObject var coreVM: CoreViewModel               // No = or (), it is not initialized here and don't want it to be
    @Environment(\.dismiss) private var dismiss
    @State private var showEraseConfirmation = false
    @State private var showShareSheet = true
    let type: ModalType
    let onAction: ((ModalAction) async throws -> Void)?       ///Pass async closures for actions
    
    /// NECESSARY: handles ObservableObject properties
    init(
        type: ModalType,
        coordinator: TetherCoordinator,
        coreVM: CoreViewModel
    ) {
        self.type = type
        //        self.coordinator = coordinator { get }
        self.coreVM = coreVM
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            
            ///Display TetherRowView for tether1/tether2
            if case .secondTether(let coil) = coreVM.currentState {
                switch type {
                case .tether1:
                    TetherRowView(
                        coordinator: coordinator, tether: coil.tether1, onZero: coreVM.isTether1Completed
                    )
                case .tether2:
                    TetherRowView(
                        coordinator: coordinator,
                        tether: coil.tether2,
                        onZero: coreVM.isTether2Completed
                    )
                case .returningUser: returningUserView
                default: EmptyView()
                }
            }
            
            /// Displays different buttons for Social Modal
            if type == .social {
                social_Buttons
            } else {
                action_Buttons
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var title: String {
        switch type {
        case .returningUser: return "Resume?:"
        case .tether1: return "Tethered to:"
        case .tether2: return "Tethered to:"
        case .completion: return "All Tasks Complete!"
        case .breakPrompt: return "Take a Break?"
        case .mindfulness: return "Mindfulness Check"
        case .social: return "Share Achievement"
        }
    }
    
    var social_Buttons: some View {
        VStack(spacing: 16) {
            if case .secondTether(let coil) = coreVM.currentState {
                Button("Share Achievement") {
                }
                .buttonStyle(.borderedProminent)
                
                Button("Skip") {
                    coordinator.navigate(to: .home)
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    var action_Buttons: some View {
        HStack(spacing: 20) {
            Button("Cancel") {
                Task { @MainActor in
                    await coordinator.navigate(to: .home)
                    dismiss()
                }
            }
            .buttonStyle(.bordered)
            
            Button("In Progress") {
                Task {
                    try await coreVM.handleModalAction(for: type, action: .inProgress)
                    dismiss()
                }
            }
            .buttonStyle(.bordered)
            .background(Color.theme.secondaryGreen)
            
            Button("Done") {
                Task {
                    try await coreVM.handleModalAction(for: type, action: .complete)
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    var homePage_Buttons: some View {
        HStack {
            Button("Start") {
                Task {
                    try? await onAction?(.inProgress)
                }
            }
            Button("Done") {
                Task {
                    try? await onAction?(.complete)
                    await MainActor.run {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var returningUserView: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.title)
                .foregroundStyle(Color.theme.primaryBlue)
            
            ///Show current state/progress
            if case .secondTether(let coil) = coreVM.currentState {
                Text("You have a session in progress")
                    .foregroundStyle(Color.theme.secondaryGreen)
                
                Button {
                coordinator.resumeUserTimerFlow()
            } label: {
                    Text("Continue Session")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.theme.buttonText)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.primaryBlue)
                        .cornerRadius(10)
                }
                // Clear data button
                Button(action: {
                    showEraseConfirmation = true
                }) {
                    Text("Clear & Start Over")
                        .foregroundStyle(Color.theme.secondaryRed)
                }
                .alert("Clear All Data?", isPresented: $showEraseConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        Task {
                            await coreVM.clearAllData()
                            dismiss()
                        }
                    }
                } message: {
                    Text("This will clear all entered data and reset the timer.")
                }
            }
        }
    }
}
enum ModalAction {
    case complete
    case inProgress
    case cancel
}
