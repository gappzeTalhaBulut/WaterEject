//
//  LogHelper.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import UIKit
import Network
import CoreTelephony

class LogHelper {
    
    static var version = { () -> String in
        let infoDict = Bundle.main.infoDictionary!
        return infoDict["CFBundleShortVersionString"] as! String
    }()
    
    static var appName: String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    }
    
    static var caName : String {
        let obj = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            if let array = obj.serviceSubscriberCellularProviders {
                return array.values.first?.carrierName ?? "None"
            }
        } else {
            // Fallback on earlier versions
        }
        return "None"
    }
    
    static var raName : String {
        let obj = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            if let accessTech = obj.serviceCurrentRadioAccessTechnology {
                return accessTech.first?.value ?? "None"
            }
        } else {
            // Fallback on earlier versions
        }
        return "None"
    }
    
    static var bundleId: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    static var deviceCountry: String {
        return Locale.current.region?.identifier ?? ""
    }
    
    static var deviceLang: String {
        return Locale.current.language.languageCode?.identifier ?? ""
    }
    
    static var deviceModel: String {
        return UIDevice.modelName
    }
    
    static var deviceName: String {
        return UIDevice.current.name
    }
    
    static var deviceOS: String {
        return UIDevice.current.systemName
    }
    
    static var deviceOSVersion: String {
        return UIDevice.current.systemVersion
    }
    
    static var deviceId: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    static var deviceBatteryLevel: Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return Int(abs(UIDevice.current.batteryLevel * 100))
    }
    
    static func deviceIp(type: NetworkType) -> String {
        return UIDevice().getIpAddress(for: type) ?? ""
    }
}
