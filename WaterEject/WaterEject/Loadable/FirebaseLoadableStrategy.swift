//
//  FirebaseLoadableStrategy.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import UIKit
import Firebase

final class FirebaseLoadableStrategy: SDKLodableStrategy {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        FirebaseApp.configure()
    }
}
