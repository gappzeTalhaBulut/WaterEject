//
//  LoadableManager.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation
import UIKit

protocol SDKLodableStrategy {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
}

final class SDKLodableManager: SDKLodableStrategy {
    private let loadables: [SDKLodableStrategy]
    
    init(loadables: [SDKLodableStrategy]) {
        self.loadables = loadables
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        loadables.forEach { $0.application(application, didFinishLaunchingWithOptions: launchOptions)}
    }
}
