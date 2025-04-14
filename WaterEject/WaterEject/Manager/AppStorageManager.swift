//
//  AppStorageManager.swift
//  WaterEject
//
//  Created by Talha on 10.04.2025.
//

import SwiftUI

class AppStorageManager: ObservableObject {
    @AppStorage("isPremium") var isPremium: Bool = false
    @AppStorage("SeenIntro") var seenIntro: Bool = false
    @AppStorage("cleaningDays") var cleaningDaysData: Data = Data()
}
