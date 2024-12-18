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
    @State private var showShareSheet = true
    let type: ModalType
    let onAction: ((ModalAction) async throws -> Void)?        ///Pass async closures for actions
    
    /// NECESSARY: handles ObservableObject properties
    init(
        type: ModalType,
//        coordinator: TetherCoordinator,
        coreVM: CoreViewModel
    ) {
        self.type = type
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
    
}

enum ModalAction {
    case complete
    case inProgress
    case cancel
}
