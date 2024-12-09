//
//  TimerView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/7/24.
//

import SwiftUI

struct TimerView: View {
    let seconds: Int
    
    var body: some View {
        VStack {
            ///Timer visual
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: CGFloat(seconds) / 1200.0)
                    .stroke(Color.theme.primaryBlue, lineWidth: 4)
                    .rotationEffect(.degrees(-90))
                
                Text(timeString)
                    .font(.title2)
                    .monospacedDigit()
            }
            .frame(width: 100, height: 100)
        }
    }
        private var timeString: String {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%d:02d", minutes, remainingSeconds )
        }
    }

//#Preview {
//    TimerView(seconds: $seconds)
//}
