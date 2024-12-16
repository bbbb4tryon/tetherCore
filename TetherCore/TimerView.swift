//
//  TimerView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/7/24.
//

import SwiftUI

struct TimerView: View {
    let seconds: Int
    let showProgress: Bool
    
    var body: some View {
        VStack {
            ///Timer visual
                ZStack {
                    if showProgress {
//                    Circle()
//                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
//                    Circle()
//                        .trim(from: 0, to: CGFloat(seconds) / 1200.0)
//                        .stroke(style: StrokeStyle( lineWidth: 4, lineCap: .round))
//                        .foregroundStyle(Color.theme.primaryBlue)
                        
                        Gauge(value: Double(seconds), in: 0...1200) {
                            Text(timeString)
                        } currentValueLabel: {
                            Text(timeString)
                        }
                        .gaugeStyle(.accessoryCircular)
                        .tint(Color.theme.primaryBlue)
                        .rotationEffect(.degrees(-90))
                    
//                    Text(timeString)
//                        .font(.title)
//                        .monospacedDigit()
//                        .frame(alignment: .center)
                }
            }
        }
        .frame(width: .infinity, height: 200)
        .padding()
    }
    private var timeString: String {
        let minutes = seconds / 60
        let text = "minutes remaining"
        return String(format: "%02d:%02d\n", minutes, text )
    }
}

//#Preview {
//    TimerView(seconds: $seconds)
//}
