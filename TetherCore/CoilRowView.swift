//
//  CoilRowView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/6/24.
//

import SwiftUI

struct CoilRowView: View {
    var coil: Coil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(coil.formattedTimestamp)
                .font(.footnote)
                .foregroundStyle(Color.theme.secondaryGreen)
            Text("\(coil.tether1.tetherText)")
                .strikethrough(coil.tether1.isCompleted)
            Text("\(coil.tether2.tetherText)")
                .strikethrough(coil.tether2.isCompleted)
          }
        .padding(.vertical, 4)
      }
}

#Preview {
    let tether1 = Tether(tetherText: "Example tether")
    let tether2 = Tether(tetherText: "2nd example", isCompleted: true)
    let sampleCoil = Coil(tether1: tether1, tether2: tether2, isCompleted: true)
    
    CoilRowView(coil: sampleCoil)
}
