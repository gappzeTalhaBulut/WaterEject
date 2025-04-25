//
//  AppOpenResponse.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation

struct AppOpenResponse: Decodable {
    let version: String?
    let isPremium: Bool?
    let isAdsActive: Bool?
    let isApple: Bool?
    let customerId: Int?
    let onboarding: Bool?
    let fromType: String?
    let fromFirstTime: Bool?
    let fromNextTime: Bool?
    let actions: PaywallAction?
    let ads: [ADSModel]?
    
    init(version: String? = nil,
         actions: PaywallAction? = nil,
         ads: [ADSModel]? = nil,
         isPremium: Bool? = false,
         isAdsActive: Bool? = true,
         isApple: Bool? = false,
         fromType: String? = nil,
         fromFirstTime: Bool? = false,
         fromNextTime: Bool? = false,
         customerId: Int? = nil,
         onboarding: Bool? = false) {
        self.version = version
        self.isPremium = isPremium
        self.isAdsActive = isAdsActive
        self.isApple = isApple
        self.actions = actions
        self.ads = ads
        self.customerId = customerId
        self.onboarding = onboarding
        self.fromType = fromType
        self.fromNextTime = fromNextTime
        self.fromFirstTime = fromFirstTime
    }
    
    private enum CodingKeys: String, CodingKey {
        case version
        case isPremium
        case isAdsActive = "isAdsActive"
        case isApple = "ia"
        case actions
        case ads
        case customerId
        case onboarding
        case fromType
        case fromNextTime
        case fromFirstTime
    }
}

struct PaywallAction: Decodable {
    let push: AppPaywall
    let premium: AppPaywall
    let onboarding: AppPaywall
    let frun: AppPaywall
    let cleanAction: AppPaywall
    let toneAction: AppPaywall
    let dbMeterAction: AppPaywall
    let stereoAction: AppPaywall
    
    func getPaywall(_ action: AppPaywallAction) -> AppPaywall {
        switch action {
        case .frunAction:
            return self.frun
        case .premium:
            return premium
        case .onboarding:
            return onboarding
        case .cleanAction:
            return cleanAction
        case .toneAction:
            return toneAction
        case .dbMeterAction:
            return dbMeterAction
        case .stereoAction:
            return stereoAction
        case .push:
            return push
        }
    }
}

struct AppPaywall: Decodable {
    let willBeShown: Bool
    let placementId: String
    let expId: Int
    let actionId: Int?
    let onClose: PaywallOnClose?
    
    private enum CodingKeys: String, CodingKey {
        case willBeShown = "show"
        case placementId = "experiment"
        case onClose
        case actionId
        case expId
    }
}

struct PaywallOnClose: Decodable {
    let open: PaywallOnCloseOpenType
    let id: Int
    let expId: Int?
    let expName: String?
    
    enum CodingKeys: String, CodingKey {
        case open
        case id
        case expId
        case expName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.open = try container.decode(PaywallOnCloseOpenType.self, forKey: .open)
        self.id = try container.decode(Int.self, forKey: .id)
        
        if self.open == .placement {
            self.expId = try container.decode(Int.self, forKey: .expId)
            self.expName = try container.decode(String.self, forKey: .expName)
        } else {
            self.expId = nil
            self.expName = nil
        }
    }
}

enum PaywallOnCloseOpenType: String, Decodable {
    case ads
    case placement
}

struct ADSModel: Decodable {
    let id: Int
    let type: ADSType
    let key: String
    let userApproval: Int
}

enum ADSType: String, Decodable {
    case appOpen
    case rewardedInterstitial
}
