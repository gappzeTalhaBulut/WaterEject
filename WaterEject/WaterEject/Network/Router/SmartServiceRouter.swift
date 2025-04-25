//
//  SmartServiceRouter.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation

enum SmartServiceRouter: NetworkEndpointConfiguration {
    case appOpen
    
    var method: HTTPMethodType {
        return .post
    }
    
    var path: String {
        return AppConfig.serURL + "/appOpen"
    }
    
    var parametersBody: Data? {
        switch self {
        case .appOpen:
            let body: [String: Any] = [
                "version": AppConfig.version,
                "paywallVersion": AppConfig.paywallVersion,
                "appVersion": LogHelper.version,
                "bundle": Config.bundleIdentifier,
                "unique-id": Config.UDID,
                "name": LogHelper.deviceName,
                "model": LogHelper.deviceModel,
                "language": LogHelper.deviceLang.uppercased(),
                "country": LogHelper.deviceCountry.uppercased(),
                "battery": LogHelper.deviceBatteryLevel,
                "os": LogHelper.deviceOS,
                "os-version": LogHelper.deviceOSVersion,
                "wifi": LogHelper.deviceIp(type: .wifi),
                "lte": LogHelper.deviceIp(type: .cellular),
                "adaptyID": AppConfig.adaptyID,
                "isTest": AppConfig.isTest,
            ]
            debugPrint("AppOpen Request Body:", body)
            return body.convert()
        }
    }
    
    var headers: [String : String] {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AppConfig.smartServiceToken)"
        ]
    }
    
    var timeoutInterval: TimeInterval {
        return 10
    }
}

extension Dictionary where Key == String, Value == Any {
    func convert() -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                debugPrint("Converted JSON:", jsonString)
            }
            return jsonData
        } catch {
            debugPrint("JSON Conversion Error:", error)
            return nil
        }
    }
}
