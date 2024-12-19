//
//  SettingsView.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/5/24.
//

import SwiftUI

struct SettingsView: View {
   
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Will Be Here")
                }
            }
            .navigationTitle("Settings")
        }
    }

extension Bundle {
    var appVersion: String {
        if let version = infoDictionary?["CFBundleShortVersionString"]as? String {
            return version
        }
        return "1.0"        ///Fallback version
    }
}

@MainActor
enum HapticStyle: String, CaseIterable, Identifiable {
    case gentle = "gentle"
    case medium = "medium"
    case strong = "strong"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .gentle: return "Gentle (...)"
        case .medium: return "Medium (--)"
        case .strong: return "Strong (-)"
        }
    }
    
    /// Local generator instances (prevents shared state
    func trigger() {
        switch self {
        case .gentle:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .strong:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
}
//#Preview {
//    SettingsView()
//}
