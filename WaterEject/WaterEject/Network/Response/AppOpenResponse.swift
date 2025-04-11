//
//  AppOpenResponse.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation

struct AppOpenResponse: Decodable {
    let version: String?
    let isPremium: Bool
    let isAdsActive: Bool?
    let actions: PaywallAction?
    let intro: Int?
    //let ads: [ADSModel]?
    
    
    init(version: String? = nil,
         actions: PaywallAction? = nil,
         //ads: [ADSModel]? = nil,
         isPremium: Bool = false,
         isAdsActive: Bool? = nil,
         isApple: Bool = false,
         intro: Int? = nil,
         customerId: Int? = nil,
         onboarding: Bool = true) {
        self.version = version
        self.isPremium = isPremium
        self.isAdsActive = isAdsActive
        self.actions = actions
     //   self.ads = ads
        self.intro = intro
    }
    
    private enum CodingKeys: String, CodingKey {
        case version
        case isPremium
        case isAdsActive = "isAdsActive"
        case actions = "paywallActions"
      //  case ads
        case intro
    }
}

struct PaywallAction: Decodable {
    let push: AppPaywall
    let premium: AppPaywall
    let onboarding: AppPaywall
    let frun: AppPaywall
    let listenAction: AppPaywall
    let createAction: AppPaywall
    let voiceCloneAction: AppPaywall
    
    func getPaywall(_ action: AppPaywallAction) -> AppPaywall {
        switch action {
        case .push: return push
        case .premium:
            return premium
        case .onboarding:
            return onboarding
        case .frunAction:
            return frun
        }
    }
}

struct AppPaywall: Decodable {
    let willBeShown: Bool
    let placementId: String
    let onClose: PaywallOnClose?
    
    private enum CodingKeys: String, CodingKey {
        case willBeShown = "show"
        case placementId = "placementId"
        case onClose
    }
}

struct PaywallOnClose: Decodable {
    let open: PaywallOnCloseOpenType
    let id: String
    
    enum CodingKeys: CodingKey {
        case open
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.open = try container.decode(PaywallOnCloseOpenType.self, forKey: .open)
        self.id = try container.decode(String.self, forKey: .id)
    }
}

enum PaywallOnCloseOpenType: String, Decodable {
    case ads
    case placement
}

struct ADSModel: Decodable {
    let id: String
    let type: ADSType
    let key: String
    let userApproval: Int
}

enum ADSType: String, Decodable {
    case appOpen
    case rewarded
}
