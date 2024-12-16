//
//  ModalView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/5/24.
//

import SwiftUI

struct ModalView: View {
    let type: ModalType
    @ObservedObject var coordinator: TetherCoordinator      // No = or (), it is not initialized here and don't want it to be
    @ObservedObject var coreVM: CoreViewModel               // No = or (), it is not initialized here and don't want it to be
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = true
    
    init(
        type: ModalType,
        coordinator: TetherCoordinator,
        coreVM: CoreViewModel
    ) {
        self.type = type
        self.coordinator = coordinator
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
                        coordinator: coordinator,
                        tether: coil.tether1,
                        isCompleted: coreVM.isTether1Completed
                    )
                case .tether2:
                    TetherRowView(
                        coordinator: coordinator,
                        tether: coil.tether2,
                        isCompleted: coreVM.isTether2Completed
                    )
                default: EmptyView()
                }
            }
            
            ///Displays Timer
            if coordinator.showTimer {
                TimerView(seconds: coreVM.timerSeconds, showProgress: true)
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
    
    private var social_Buttons: some View {
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
    
    private var action_Buttons: some View {
        HStack(spacing: 20) {
            Button("Cancel") {
                coordinator.navigate(to: .home)
                dismiss()
            }
            .buttonStyle(.bordered)
            
            Button("In Progress") {
                coreVM.handleModalAction(for: type, action: .inProgress)
                dismiss()
            }
            .buttonStyle(.bordered)
            .background(Color.theme.secondaryGreen)
            
            Button("Done") {
                coreVM.handleModalAction(for: type, action: .complete)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

enum ModalAction {
    case complete
    case inProgress
    case cancel
}
