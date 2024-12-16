//
//  ProgressDecrement.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/15/24.
//

import SwiftUI

struct ProgressDecrement: View {
    let duration: TimeInterval
    let label: String
    @State private var progress: Double = 1.0   /// Start full, then decrease
    
    var body: some View {
        VStack {
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(.circular)
                .tint(Color.theme.primaryBlue)
                .scaleEffect(1.5)
            Text(label)
        }
        .task {
            await decrementProgress()
        }
    }
    
    private func decrementProgress() async {
        while progress > 0 {
            try? await Task.sleep(for: .microseconds(100))
            withAnimation {
                progress -= 0.1 / (duration/1.0)
            }
        }
    }
}

