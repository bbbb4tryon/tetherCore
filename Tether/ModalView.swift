//
//  ModalView.swift
//  Tether
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
    ///     Remember: match to how it is used (may need modification as you build)
    init(
        type: ModalType,
        coreVM: CoreViewModel,
        onAction: ((ModalAction) async throws -> Void)? = nil
    ){
        self.type = type
        self.coreVM = coreVM
        self.onAction = onAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            
            ///Display TetherRowView for tether1/tether2
            if case .secondTether(let coil) = coreVM.currentState {
                switch type {
                case .permissions:
                               VStack(spacing: 16) {
                                   Text("Tether helps maintain your focus sessions.")
                                       .multilineTextAlignment(.center)
                                   
                                   Button("Get Started") {
                                       Task {
                                           HapticStyle.gentle.trigger()
                                           try? await coreVM.handleModalAction(for: type, action: .complete)
                                       }
                                   }
                                   .buttonStyle(.borderedProminent)
                               }
                               .padding()
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
                case .returningUser: returningUser_Buttons
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
        case .permissions: return "Welcome to Tether"
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
            if case .secondTether(_) = coreVM.currentState {    ///underscore pattern matching instead of 'let coil' preserves type safety, ignores unused values 
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
    
    var returningUser_Buttons: some View {
        VStack(spacing: 24){
            /// A clear hierarchy with session info
            VStack(spacing: 16) {
                Text("Welcome Back!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.theme.primaryBlue)
                
                ///Show current state/progress
                if case .secondTether(let coil) = coreVM.currentState {
                    /// Show actual user progress
                    VStack(spacing: 8){
                        HStack {
                            Text("Current Progress")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 4){
                            Text("􀓩 \(coil.tether1.tetherText)")
                                .strikethrough(coil.tether1.isCompleted)
                            Text("􀓩 \(coil.tether2.tetherText)")
                                .strikethrough(coil.tether2.isCompleted)
                        }
                        .foregroundStyle(Color.black)
                    }
                    .padding()
                    .background(Color.theme.secondaryGreen.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            /// A clear hierarchy
            VStack(spacing: 12) {
                Button(action: {
                    Task { @MainActor in
                        try await coordinator.resumeUserTimerFlow()
                    }
                }, label: {
                    Text("Resume Your Session")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.primaryBlue)
                        .foregroundStyle(Color.theme.buttonText)
                        .cornerRadius(10)
                }
                )
                
                ///Start over button, includes a confirmation
                Button(action: {
                    showEraseConfirmation = true
                }) {
                    Text("Delete & Start Over")
                        .foregroundStyle(Color.theme.accentSalmon)
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
