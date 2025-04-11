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
        return  ""
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
            debugPrint(body)
            return body.convert()
           
        }
    }
    
    var headers: [String : String] {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer"
        ]
    }
    
    var timeoutInterval: TimeInterval {
        return 10
    }
}
extension Dictionary where Key == String, Value == Any {
    func convert() -> Data? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) else { return  nil }
        guard let json = String(data: data, encoding: .utf8) else { return nil}
        return json.data(using: .utf8)
    }
}
