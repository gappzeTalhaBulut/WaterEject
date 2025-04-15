//
//  OnesignalLoadableStrategy.swift
//  WaterEject
//
//  Created by Talha on 15.04.2025.
//

import Foundation
import OneSignalFramework

final class OneSignalLoadableStrategy: SDKLodableStrategy {
    private let sdkID = "c232970c-974a-4607-b58f-63b9cda2451f"
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
