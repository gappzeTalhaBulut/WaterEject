//
//  KeychainRepository.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import UIKit
import KeychainSwift

final class KeychainRepository {
    private let keychain: KeychainSwift
    
    static let shared = KeychainRepository()

    private init() {
        self.keychain = KeychainSwift()
    }
    
    func getUDID() {
        if keychain.get("UDID") == nil {
            let udid = UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: "")
            keychain.set(udid, forKey: "UDID")
            Config.UDID = udid
        } else {
            let udid = String(format: "%@", keychain.get("UDID")!)
            Config.UDID = udid
        }
    }
    
    func setFirstOpen(firstInstallBlock: () -> ()) {
        if keychain.get("FirstInstall") == nil {
            firstInstallBlock()
            keychain.set(true, forKey: "FirstInstall")
        }
    }
}
