//
//  LoadingOverlay.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/20/24.
//

import SwiftUI

/// No need to declare coreVM, the property declaration is already created in CoreView
struct LoadingOverlay: View {
    
    var body: some View {
        ZStack {
            ///Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .tint(Color.theme.primaryBlue)
                Text("Loading...")
                    .foregroundStyle(Color.theme.primaryBlue)
            }
            .padding(24)
            .background(Color.theme.background)
            .cornerRadius(12)
            .shadow(radius: 5)
            
        }
    }
}
