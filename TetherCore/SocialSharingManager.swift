//
//  SocialSharingManager.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/11/24.
//

import Foundation

actor SocialSharingManager {
    private let locale = Locale.current
    private var isInChina: Bool {
        locale.region?.identifier == "CN"
    }
    
    func share(coil: Coil, to platform: SocialPlatform) async throws {
        ///Validate region
        guard validatePlatformAvailability(platform) else {
            throw SocialError.regionRestricted
        }
        
        /// Platform logic
        switch platform {
        case .tiktok: try await shareTikTok(coil)
        case .instagram: try await shareInstagram(coil)
        case .linkedin: try await shareLinkedIn(coil)
        case .wechat: try await shareWeChat(coil)
        case .douyin: try await shareDouyin(coil)
        }
    }
    
    private func validatePlatformAvailability(_ platform: SocialPlatform) -> Bool {
        if isInChina {
            return platform.isAvailableInChina
        }
        return !platform.isAvailableInChina
    }
    
}
