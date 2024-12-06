//
//  ProfileView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/5/24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        Text("Profile")
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(.theme.primaryBlue)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 300)
            .padding(.vertical, 20)
            .shadow(color: Color.theme.primaryBlue.opacity(0.2), radius: 2, y: 2)
    }
}

#Preview {
    ProfileView()
}
