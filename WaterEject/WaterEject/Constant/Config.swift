//
//  Config.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation
enum Config {
    static var premium = UserDefaults.standard.bool(forKey: "Premium")
    static var UDID: String = ""
    static var appStoreMyApps: String = "" // yanlış
    static var privacy: String = ""
    static var terms: String = ""
    static let appUrl: String = "https://itunes.apple.com/app/id6025" // doğru
    static let reviewURL: String = "https://apps.apple.com/app/id67331?action=write-review" // yanlış
    
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    static var isAdsActive: Bool = true
    static var api_key: String = ""
}
