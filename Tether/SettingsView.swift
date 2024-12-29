//
//  SettingsView.swift
//  Tether
//
//  Created by Benjamin Tryon on 12/5/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("deviceID") private var useDeviceID = (UIDevice.current.identifierForVendor?.uuidString ?? "Not Available")
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("timerHaptics") private var timerHaptics = HapticStyle.gentle
    @AppStorage("reminderHaptics") private var reminderHaptics = HapticStyle.strong
    
    var body: some View {
        NavigationStack {
            List {
                ///Device info section
                Section("Device") {
                    Text("Device ID: \(useDeviceID ?? "Unknown")")
                        .font(.system(.subheadline, design: .monospaced))
                }
                
                ///Notifications Section
                Section {
                    Toggle("Enable Reminders", isOn: $notificationsEnabled)
                    
                    ///Timer Haptics
                    Picker("Timer Complete", selection: $timerHaptics) {
                        ForEach(HapticStyle.allCases) { style in
                            Text(style.description).tag(style)
                        }
                    }
                    
                    ///Reminder Haptics
                    Picker("Reminder Style", selection: $reminderHaptics) {
                        ForEach(HapticStyle.allCases) { style in
                            Text(style.description).tag(style)
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Only haptic feedback, no sounds")
                }
                
                ///App Info Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundStyle(Color.theme.secondaryGreen)
                    }
                }
            }
            .navigationTitle("Settings")
        }
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
