//
//  TimePieceView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/7/24.
//

import SwiftUI

struct TimePieceView: View {
    @EnvironmentObject var coordinator: TetherCoordinator
    let seconds: Int
    let showProgress: Bool
    let label: String?
    let onZero: (() async -> Void)?
    
    var body: some View {
        VStack {
            ///Timer visual/UI
                ZStack {
                    ///Base circle
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    ///Progress pie
                    Circle()
                        .trim(from: 0, to: CGFloat(seconds) / 1200.0)
                        .stroke(Color.theme.primaryBlue, lineWidth: 4)
                        .rotationEffect(.degrees(-90))
                    
                    ///Timer values
                    Text(timeString)
                        .font(.system(.title2, design: .monospaced))
                        .foregroundStyle(Color.theme.primaryBlue)
            }
                .frame(width: 100, height: 100)
        }
        .onChange(of: seconds) { _,newValue in
            if newValue == 0 {
                Task { @MainActor in
                    await onZero?()        ///Optional Chaining
                    coordinator.showTimer(false)
                }
            }
        }
    }
    
    private var timeString: String {
        let minutes = seconds / 60
        return String(format: "%02d", minutes)
    }
}
//
///// Extension: Modal dependent timer control
//extension CoreViewModel {
//    func handleTimerControl(action: ModalAction) {
//        switch action {
//        case .inProgress:
//            Task {
//                await startTimer()
//                coordinator.showClock(true)
//            }
//        case .cancel:
//            Task {
//                await mainTimer.stop()
//                coordinator.showClock(false)
//            }
//        default:
//            break
//        }
//    }
//    
//    func submitTether() {
//        guard !currentTetherText.isEmpty else { return }
//        let newTether = Tether(tetherText: currentTetherText)
//        
//        switch currentState {
//        case .empty:
//            currentState = .firstTether(newTether)
//            
//        case .firstTether(let firstTether):
//            let coil = Coil(tether1: firstTether, tether2: newTether)
//            currentState = .secondTether(coil)
//            Task {
//                try? await storage.saveCoil(coil)
//                await startTimer()
//                coordinator.showClock(true)
//                coordinator.navigate(to: .tether1Modal)
//            }
//            
//        case .secondTether, .completed:
//            break
//        }
//        currentTetherText = ""
//}
//
////#Preview {
////    TimePieceView(seconds: $seconds)
////}
