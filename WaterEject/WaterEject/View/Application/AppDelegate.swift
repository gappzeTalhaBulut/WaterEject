//
//  AppDelegate.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private lazy var sdkLoadableManager: SDKLodableStrategy = {
        let manager = SDKLodableManager(loadables: [
            FirebaseLoadableStrategy(),
            OneSignalLoadableStrategy(),
        ])
        return manager
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        applicationSetup()
        sdkLoadableManager.application(application, didFinishLaunchingWithOptions: launchOptions)
        Task {
            await initializePayWall()
        }
        return true
    }
    
    private func initializePayWall() async {
        do {
            try await AdaptyService.shared.initializeAdapty()
        } catch {
            print("Failed to initialize Adapty:", error.localizedDescription)
        }
    }
}

extension AppDelegate {
    func applicationSetup() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        KeychainRepository.shared.getUDID()
    }
}
