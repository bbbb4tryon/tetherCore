//
//  ModalView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/5/24.
//

import SwiftUI

struct ModalView: View {
    let type: ModalType
    let onComplete: () -> Void
    let onInProgress: () -> Void
    let onCancel: () -> Void
    @ObservedObject var coreVM: CoreViewModel            ///No = or (), it is not initialized here and don't want it to be
//    @State private var tetherInsert: [Tether] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            
            ///Uses TetherRowView for display
            if let coil = coreVM.currentCoil {
                switch type {
                case .tether1:
                    TetherRowView(
                        tether: coil.tether1,
                        isCompleted: coil.tether1.isCompleted
                    )
                case .tether2:
                    TetherRowView(
                        tether: coil.tether2,
                        isCompleted: coil.tether2.isCompleted
                    )
                default: EmptyView()
                }
            }
            
            ///Show Timer
            if coreVM.showTimer {
                TimerView(seconds: coreVM.timerSeconds)
            }

            HStack(spacing: 20) {
                Button("Cancel") {
                    onCancel()
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("In Progress") {
                    onInProgress()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .foregroundColor(Color.theme.secondaryGreen)
                
                Button("Done") {
                    onComplete()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.theme.primaryBlue)
            }
        }
        .padding()
    }
    
    private var title: String {
        switch type {
        case .tether1: return "Tethered to:"
        case .tether2: return "Tethered to:"
        case .completion: return "All Tasks Complete!"
        case .breakPrompt: return "Take a Break?"
        case .mindfulness: return "Mindfulness Check"
        case .social: return "Send to Social"
        }
    }
}

enum ModalAction {
    case complete
    case inProgress
    case cancel
}
