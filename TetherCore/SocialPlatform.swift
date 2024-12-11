//
//  SocialPlatform.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/11/24.
//

import SwiftUI

enum SocialPlatform: String {
    case tiktok = "TikTok"
    case instagram = "Instagram"
    case linkedin = "LinkedIn"
    case wechat = "WeChat"
    case douyin = "Douyin"
    
    var isAvailableInChina: Bool {
        switch self {
        case .wechat, .douyin: return true
        case .tiktok, .instagram, .linkedin: return false
        }
    }
    
}
