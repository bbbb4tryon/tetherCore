//
//  TetherRowView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/7/24.
//

import SwiftUI

struct TetherRowView: View {
    let tether: Tether
    let isCompleted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tether.tetherText)
                .font(.body)
                .foregroundStyle(Color.theme.primaryBlue)
                .strikethrough(isCompleted)
            
            Text(tether.timeStamp.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryGreen)
        }
        .padding(.vertical, 4)
    }
}

