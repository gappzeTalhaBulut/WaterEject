//
//  OnesignalLoadableStrategy.swift
//  WaterEject
//
//  Created by Talha on 15.04.2025.
//

import Foundation
import OneSignalFramework

final class OneSignalLoadableStrategy: SDKLodableStrategy {
    private let sdkID = "9fcfb5f4-ba06-4956-aea7-1870eeca9aac"
    private let permissionRequestCountKey = "permissionRequestCount"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        OneSignal.initialize(sdkID, withLaunchOptions: launchOptions)
        OneSignal.login(Config.UDID)

        let userDefaults = UserDefaults.standard
        let requestCount = userDefaults.integer(forKey: permissionRequestCountKey)

        if requestCount < 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                OneSignal.Notifications.requestPermission({ accepted in
                    print("User accepted notifications: \(accepted)")
                    // İzin isteği sayısını güncelle
                    userDefaults.set(requestCount + 1, forKey: self.permissionRequestCountKey)
                }, fallbackToSettings: false)
            }
        }
    }
}
