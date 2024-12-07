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
    private let storage = TetherStorageManager()        ///storage a regular property
    private let coreVM = CoreViewModel()
//    @State private var tetherInsert: [Tether] = []
    var tether: Tether
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            List {
                ForEach(tether.tetherText) { tether in
                    Tether(tether: coreVM.newTether)
                }
            }
            .task {
                let showThenAdd = await tether.init()
                tInput = showThenAdd.tetherText
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
        }
    }
}

extension CoreViewModel {
    func handleModalAction(for type: ModalType, action: ModalAction) {
        switch (type, action) {
        case (.tether1, .complete):
            currentCoil?.tether1.isCompleted = true
        case (.tether2, .complete):
            currentCoil?.tether2.isCompleted = true
        case (_, .inProgress):
            // Handle in-progress state
            break
        case (_, .cancel):
            // Reset or handle cancellation
            break
        default:
            break
        }
    }
}

enum ModalAction {
    case complete
    case inProgress
    case cancel
}
