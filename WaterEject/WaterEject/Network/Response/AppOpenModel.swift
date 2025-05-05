//
//  AppOpenModel.swift
//  WaterEject
//
//  Created by Talha on 5.05.2025.
//

import Foundation

enum AdConfig {
    static var attribution: Bool = false
    static var orgId: Int = 0
    static var campaignId: Int = 0
    static var conversionType = ""
    static var adGroupId: Int = 0
    static var countryOrRegion = ""
    static var keywordId: Int = 0
    static var adId: Int = 0
    static var clickDate = ""
}

struct AttributionData {
    let attribution: Bool
    let orgId: Int
    let campaignId: Int
    let conversionType: String
    let adGroupId: Int
    let countryOrRegion: String
    let keywordId: Int
    let adId: Int
    let clickDate: String
    
    init() {
        self.attribution = AdConfig.attribution
        self.orgId = AdConfig.orgId
        self.campaignId = AdConfig.campaignId
        self.conversionType = AdConfig.conversionType
        self.adGroupId = AdConfig.adGroupId
        self.countryOrRegion = AdConfig.countryOrRegion
        self.keywordId = AdConfig.keywordId
        self.adId = AdConfig.adId
        self.clickDate = AdConfig.clickDate
    }
}

struct AppOpenModel {
    let bundle: String
    let battery: Int
    let country: String
    let lang: String
    let lte: String
    let model: String
    let name: String
    let os: String
    let osVersion: String
    let paywallVersion: String
    let pushServiceClientId: String
    let uniqueId: String
    let version: String
    let wifi: String
    let isTest: Bool
    let appVersion: String
    let serviceType: String
    let from: AttributionData
    
    init() {
        self.bundle = Config.bundleIdentifier
        self.battery = LogHelper.deviceBatteryLevel
        self.country = LogHelper.deviceCountry.uppercased()
        self.lang = LogHelper.deviceLang.uppercased()
        self.lte = LogHelper.deviceIp(type: .cellular)
        self.model = LogHelper.deviceModel
        self.name = LogHelper.deviceName
        self.os = LogHelper.deviceOS
        self.osVersion = AppConfig.version
        self.paywallVersion = AppConfig.paywallVersion
        self.pushServiceClientId = AppConfig.pushtoken
        self.uniqueId = Config.UDID
        self.version = AppConfig.version
        self.wifi = LogHelper.deviceIp(type: .wifi)
        self.isTest = AppConfig.isTest
        self.appVersion = LogHelper.version
        self.serviceType = ServiceType.adapty.rawValue
        self.from = AttributionData()
    }
    
    func fromData() -> Any {
        if !AdConfig.attribution {
            return false
        }
        return [
            "type": "appleSearchAds",
            "data": [
                "attribution": from.attribution,
                "orgId": from.orgId,
                "campaignId": from.campaignId,
                "conversionType": from.conversionType,
                "adGroupId": from.adGroupId,
                "countryOrRegion": from.countryOrRegion,
                "keywordId": from.keywordId,
                "adId": from.adId,
                "clickDate": from.clickDate
            ]
        ]
    }
}


enum ServiceType: String {
    case manas
    case adapty
}
