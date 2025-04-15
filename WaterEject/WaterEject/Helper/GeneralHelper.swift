//
//  GeneralHelper.swift
//  WaterEject
//
//  Created by Talha on 15.04.2025.
//

import UIKit
import StoreKit

final class GeneralHelper {
    static let shared = GeneralHelper()
    private init() {}
    
    func rateUs() {
        SKStoreReviewController.requestReviewInCurrentScene()
    }
    
    func open(link: String) {
        if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
private extension SKStoreReviewController {
    
    static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: {
                $0.activationState == .foregroundActive
            }) as? UIWindowScene {
            requestReview(in: scene)
        }
    }
}
