//
//  DisplayUnderInput.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/8/24.
//

import SwiftUI

struct DisplayUnderInput: View {
    let tether: Tether
    let onClear: () -> Void
    
    var body: some View {
        HStack {
            Text(tether.tetherText)
                .foregroundStyle(Color.theme.secondaryGreen)
            Spacer()
            Button(action: onClear) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.theme.background)
            }
        }
        .padding(.horizontal)
    }
}
