//
//  TetherRowView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/7/24.
//

import SwiftUI

struct TetherRowView: View {
    @ObservedObject var coordinator: TetherCoordinator
    let tether: Tether
    let onZero: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(tether.tetherText)
                .font(.body)
                .foregroundStyle(Color.theme.primaryBlue)
                .strikethrough(onZero)
            
            Text(tether.timeStamp.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryGreen)
                .padding()
            
        }
        .padding()
        HStack {
            Text(tether.timeStamp.formatted(
                .dateTime
                    .month(.defaultDigits)
                    .day(.twoDigits)
            ))
        }
    }
}

