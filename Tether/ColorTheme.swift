//
//  ColorTheme.swift
//  Tether
//
//  Created by Benjamin Tryon on 11/28/24.
//


import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let background = Color("Background")
    let primaryBlue = Color("primaryBlue")
    let secondaryGreen = Color("secondaryGreen")
    let accentSalmon = Color("accentSalmon")
    
    // Semantic colors for specific use cases
    let tetherBackground = Color("primaryBlue").opacity(0.5)
    let timerBackground = Color("secondaryGreen").opacity(0.5)
    let buttonBackground = Color("primaryBlue")
    let buttonText = Color("Background")
    let component = Color("accentSalmon").opacity(0.8)
}
