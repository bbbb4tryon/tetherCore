//
//  ProfileView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/5/24.
//

import SwiftUI

struct ProfileView: View {
    private let storage = TetherStorageManager()  ///storage a regular property
    @State private var intendedCoils: [Coil] = []         ///@State remains for coils array to trigger UI updates
    @State private var completedCoils: [Coil] = []
    
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
                
                List {
                    Section("Intended Actions") {
                        ForEach(intendedCoils) { coil in
                            CoilRowView(coil: coil)
                        }
                    }
                    
                    Section("Completed Actions") {
                        ForEach(completedCoils) { coil in
                            CoilRowView(coil: coil)
                        }
                    }
                }
                .task {
                    let allCoils = await storage.loadCoils()
                    intendedCoils = allCoils.filter { !$0.isCompleted }
                    completedCoils = allCoils.filter { !$0.isCompleted }
                }
            }
        }
    }
        func moveCoilToCompleted(_ coil: Coil) async {
            var movingDown = coil
            movingDown.isCompleted = true
            completedCoils.insert(movingDown, at: 0)
            intendedCoils.removeAll { $0.id == coil.id }
            
            if completedCoils.count > storage.maxCoils {
                completedCoils.removeLast()
            }
        }
    }

#Preview {
    ProfileView()
}
