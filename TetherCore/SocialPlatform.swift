//
//  SocialPlatform.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/11/24.
//

import SwiftUI

enum SocialPlatform: String {
    case linkedIn = "linkedIn"
    case weixin = "WeChat"
}
//    var isAvailableInChina: Bool {
//        switch self {
//        case .weixin: return true
//        case .linkedIn: return false
//        }
//    }    
//}

@MainActor
extension ModalView {
    internal func showShareSheet(_ coil: Coil) async {
        let text = """
        I just completed focus tasked and stayed tethered on TetherCore:
        
        Task 1: \(coil.tether1.tetherText)
        Task 2: \(coil.tether2.tetherText)
        #productivity #focus #TetherCore
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        /// Don't use guard here- even if window scene fails, don't crash - just skip sharing
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        } else {
            coordinator.navigate(to: .home)
        }
    }
}

