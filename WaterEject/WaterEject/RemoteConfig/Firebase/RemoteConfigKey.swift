//
//  RemoteConfigKey.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation

enum FireBaseRemoteConfigKey: String, CaseIterable, ConfigKey {
    case smartServiceURL
    case appOpen
    case privacy
    case terms
    case eventUrl
    case eventsUrl
    case apiKey
    case webhook
    case isLive
    case errorWebhook
    case copyRight
    case premiumLimit
    case normalLimit
    case convertUrl
    case convertKey
    case musicKey
    case googleKey
    case proxy
    case storyLimit
    case narrateLimit
    case VoiceCloneText
    
    var name: String {
        return self.rawValue
    }
    
    var offline: Any {
        switch self {
        case .smartServiceURL:
            return ""
        case .privacy:
            return ""
        case .terms:
            return ""
        case .appOpen:
            return AppOpenResponse()
        case .eventUrl:
            return ""
        case .eventsUrl:
            return ""
        case .webhook:
            return ""
        case .isLive:
            return 1
        case .errorWebhook:
            return ""
        case .apiKey:
            return ""
        case .copyRight:
            return ""
        case .normalLimit:
            return 0
        case .premiumLimit:
            return 0
        case .convertUrl:
            return ""
        case .convertKey:
            return ""
        case .musicKey:
            return ""
        case .googleKey:
            return ""
        case .proxy:
            return ""
        case .storyLimit:
            return 0
        case .narrateLimit:
            return 0
        case .VoiceCloneText:
            return "The quick brown fox jumps over the lazy dog"
        }
    }
}
