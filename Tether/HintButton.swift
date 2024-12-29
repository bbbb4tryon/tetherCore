//
//  HintButton.swift
//  Tether
//
//  Created by Benjamin Tryon on 12/28/24.
//

import SwiftUI

struct HintButton: View {
    @Binding var showTooltip: Bool
    
    var body: some View {
            Button {
                withAnimation {
                    showTooltip.toggle()
                }
            } label: {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.theme.primaryBlue)
                    .padding()
                    .background(
                        Circle()
                            .fill(.white)
                            .shadow(radius: 4)
                    )
            }
            .overlay {
                if showTooltip {
                    VStack(alignment: .leading) {
                        Text("Need Help?")
                            .font(.headline)
                        Text("Tap anywhere to see tips")
                            .font(.caption)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .shadow(radius: 4)
                    )
                    .offset(x: -120, y: -20)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
