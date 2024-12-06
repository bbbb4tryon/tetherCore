//
//  ProfileView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/5/24.
//

import SwiftUI

struct ProfileView: View {
    private let storage = TetherStorageManager()        ///storage a regular property
    @State private var coils: [Coil] = []             ///@State remains for coils array to trigger UI updates
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Profile")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.theme.primaryBlue)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                    .padding(.vertical, 20)
                    .shadow(color: Color.theme.primaryBlue.opacity(0.2), radius: 2, y: 2)
                
                List(coils) { coil in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Created: \(coil.formattedTimestamp)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("1. \(coil.tether1.tetherText)")
                            .strikethrough(coil.tether1.isCompleted)
                        
                        Text("2. \(coil.tether2.tetherText)")
                            .strikethrough(coil.tether2.isCompleted)
                    }
                }
                .navigationTitle("History")
                .task {
                    coils = await storage.loadCoils()
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
