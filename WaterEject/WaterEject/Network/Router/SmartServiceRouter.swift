//
//  SmartServiceRouter.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation

enum SmartServiceRouter: NetworkEndpointConfiguration {
    case appOpen(model: AppOpenModel)
    
    var method: HTTPMethodType {
        return .post
    }
    
    var path: String {
        return AppConfig.serURL + "/appOpen"
    }
    
    var parametersBody: Data? {
        switch self {
        case .appOpen(let model):
            let body: [String: Any] = [
                "version": model.version,
                "paywallVersion": model.paywallVersion,
                "bundle": model.bundle,
                "unique-id": model.uniqueId,
                "name": model.name,
                "model": model.model,
                "lang": model.lang,
                "country": model.country,
                "battery": model.battery,
                "os": model.os,
                "os-version": model.osVersion,
                "wifi": model.wifi,
                "lte": model.lte,
                "pushServiceClientId": model.pushServiceClientId,
                "isTest": model.isTest,
                "serviceType": model.serviceType,
                "appVersion": model.appVersion,
                "from": model.fromData()
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
