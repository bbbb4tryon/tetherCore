//
//  ContinueOverlay.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/20/24.
//

import SwiftUI

///
/// No need to declare coreVM, the property declaration is already created in CoreVeiw
struct ContinueOverlay: View {
    @EnvironmentObject private var coordinator: TetherCoordinator
    @ObservedObject var coreVM: CoreViewModel
    
    var body: some View {
        ZStack {
            ///Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Continue where you left off?")
                    .font(.headline)
                    .foregroundStyle(Color.theme.primaryBlue)
                
                HStack(spacing: 30) {
                    Button("Start Over") {
                        Task { @MainActor in
                            await coreVM.clearEverythingFromUI()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Continue?"){
                        coordinator.handleReturningUser(coreVM.currentState)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

