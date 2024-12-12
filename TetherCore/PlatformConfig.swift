//
//  PlatformConfig.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/11/24.
//

import SwiftUI

struct PlatformConfig {
    static let bundleId = "com.argonnesoftware.TetherCore"
    
    ///TikTok
    static let tiktokClientKey = "YOUR_TIKTOK_CLIENT_KEY"
    static let tiktokRedirectURI = "\(bundleId)://tiktok-auth"
    
    // Instagram
    static let instagramClientId = "YOUR_INSTAGRAM_CLIENT_ID"
    static let instagramRedirectURI = "\(bundleId)://instagram-auth"
    
    // LinkedIn
    static let linkedinClientId = "YOUR_LINKEDIN_CLIENT_ID"
    static let linkedinRedirectURI = "\(bundleId)://linkedin-auth"
    
    // WeChat
    static let wechatAppId = "YOUR_WECHAT_APP_ID"
    static let wechatUniversalLink = "https://your-domain.com/wechat"
    
    // Douyin
    static let douyinClientKey = "YOUR_DOUYIN_CLIENT_KEY"
    static let douyinRedirectURI = "\(bundleId)://douyin-auth"
}

extension SocialPlatform {
    //? No force-unwrapping implementation
    var appURL: URL {
        switch self {
        case .tiktok: return URL(string: "tiktok://")!
        case .instagram: return URL(string: "instagram://")
        case .linkedin: return URL(string: "linkedin://")
        case .wechat: return URL( string: "weixin://")
        case .douyin: return URL
        }
    }
}
