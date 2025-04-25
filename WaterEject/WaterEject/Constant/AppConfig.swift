//
//  AppConfig.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation
import UIKit

//TODO -> doldurulacak
enum AppConfig {
    static let appID = "" // doğru
    static var pushtoken = UserDefaults.standard.string(forKey: "OneSignalPushPlayerID") ?? ""
    static var eventService = ""
    static var webhookService = ""
    static var errorWebhook = ""
    static var serURL = ""
    static var terms = ""
    static var privacy = ""
    static var apiKey = ""
    static var normalLimit = 1
    static var premiumLimit = 25
    static var convertUrl = ""
    static var convertKey = ""
    static var storyLimit = 2
    static var narrateLimit = 3
    static var googleKey = ""
    static var proxy: String = ""
    static var smartServiceToken = "YNUZ0OUVHQKZVDUSVTSPOU83GKDLX4ED"

    // Uygulamada geliştirme yaparken bu flag true olarak kalıcak ki boşuna event servise istek gitmesin
    static var isTest: Bool = false
    /// Backend versiyonu için kullanılacak.
    static let version = "11"
    /// Uygulama içi satınalma SDK ' sının versiyonu olucak.
    static let paywallVersion = "2"
    /// adapty id
    ///
    static var adaptyID: String = ""
    static var customerID: String = ""

}
