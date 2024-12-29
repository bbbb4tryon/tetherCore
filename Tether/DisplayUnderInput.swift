//
//  DisplayUnderInput.swift
//  Tether
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
            Spacer()
            Button(action: onClear) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.theme.background)
            }
        }
        .padding(.horizontal)
    }
}
