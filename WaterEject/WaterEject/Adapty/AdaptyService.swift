//
//  AdaptyService.swift
//  WaterEject
//
//  Created by Talha on 10.04.2025.
//

import SwiftUI
import Adapty
import AdaptyUI
import AlertKit

protocol AdaptyAnalyticsDelegate: AnyObject {
    func onPaywallOpen(paywallName: String, isABTest: Bool, abTestName: String)
    func onPaywallClose()
    func onPurchaseSuccess(purchaseTransactionId: String, paywallName: String, productId: String, isABTest: Bool, abTestName: String, price: String, priceSymbol: String)
    func onPurchaseFailed(paywallName: String, isABTest: Bool, abTestName: String, productCode: String, errorCode: String, errorDetail: String, price: String, priceSymbol: String)
    func onRestoreSuccess()
}

@MainActor
final class AdaptyService: ObservableObject {
    static let shared = AdaptyService()
    
    // MARK: - Properties
    weak var analyticsDelegate: AdaptyAnalyticsDelegate?
    
    @Published var isPaywallPresented = false
    @Published private(set) var paywall: AdaptyPaywall?
    @Published private(set) var paywallConfiguration: AdaptyUI.PaywallConfiguration?
    
    private init() {}
    
    // MARK: - Public Methods
    func initializeAdapty() {
        Adapty.activate("public_live_tDlH2mi6.cOn07VaOAVOZUsfQcxDP") // API key'i buraya ekleyin
        
        let adaptyUIConfiguration = AdaptyUI.Configuration(
            mediaCacheConfiguration: .init(
                memoryStorageTotalCostLimit: 100 * 1024 * 1024,
                memoryStorageCountLimit: .max,
                diskStorageSizeLimit: 100 * 1024 * 1024
            )
        )
        AdaptyUI.activate(configuration: adaptyUIConfiguration)
    }
    
    func openPaywall(placementId: String) async throws {
        do {
            let locale = String(Locale.current.identifier.prefix(2))
            let paywall = try await Adapty.getPaywall(placementId: placementId, locale: locale)
            
            if paywall.hasViewConfiguration {
                let products = try? await Adapty.getPaywallProducts(paywall: paywall)
                let configuration = try await AdaptyUI.getPaywallConfiguration(
                    forPaywall: paywall,
                    products: products
                )
                await showPaywall(paywall: paywall, configuration: configuration)
            } else {
                print("Paywall has no view configuration")
            }
        } catch {
            print("Error opening paywall: \(error)")
            throw error
        }
    }
    
    private func showPaywall(paywall: AdaptyPaywall, configuration: AdaptyUI.PaywallConfiguration) async {
        self.paywall = paywall
        self.paywallConfiguration = configuration
        self.isPaywallPresented = true
        self.analyticsDelegate?.onPaywallOpen(
            paywallName: paywall.name,
            isABTest: paywall.abTestName != paywall.name,
            abTestName: paywall.abTestName
        )
    }
    
    func hidePaywall() {
        isPaywallPresented = false
        paywall = nil
        paywallConfiguration = nil
    }
    
    func getAdaptyId() async -> String {
        do {
            let profile = try await Adapty.getProfile()
            return profile.profileId
        } catch {
            return "\(error)"
        }
    }
    
    func checkSubscriptionStatus() async -> (isPremium: Bool, originalTransactionId: String) {
        do {
            let profile = try await Adapty.getProfile()
            let originalTransactionId = profile.subscriptions.values.first?.vendorOriginalTransactionId ?? ""
            let isPremium = profile.accessLevels["premium"]?.isActive ?? false
            return (isPremium, originalTransactionId)
        } catch {
            return (false, "")
        }
    }
    
    func checkUser(completion: @escaping (_ isPremium: Bool, _ originalTransactionId: String) -> ()) {
        Adapty.getProfile { result in
            if let profile = try? result.get() {
                let originalTransactionId = profile.subscriptions.values.first?.vendorOriginalTransactionId ?? ""
                let isPremium = profile.accessLevels["premium"]?.isActive ?? false
                completion(isPremium, originalTransactionId)
            } else {
                completion(false, "")
            }
        }
    }
    
    func restorePurchases() async throws {
        let profile = try await Adapty.restorePurchases()
        let isPremium = profile.accessLevels["premium"]?.isActive ?? false
        debugPrint(isPremium)
        if isPremium {
            await MainActor.run {
                self.analyticsDelegate?.onRestoreSuccess()
                self.isPaywallPresented = false
            }
        } else {
            throw NSError(domain: "AdaptyService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Premium subscription not found"])
        }
    }
}

// MARK: - AdaptyPaywallControllerDelegate
extension AdaptyService: AdaptyPaywallControllerDelegate {
    func paywallController(_ controller: AdaptyPaywallController, didFinishPurchase product: AdaptyPaywallProduct, purchaseResult: AdaptyPurchaseResult) {
        guard let paywall = self.paywall else { return }
        analyticsDelegate?.onPurchaseSuccess(
            purchaseTransactionId: purchaseResult.profile?.profileId ?? "",
            paywallName: paywall.placementId,
            productId: product.vendorProductId,
            isABTest: paywall.abTestName != paywall.name,
            abTestName: paywall.abTestName,
            price: product.price.description,
            priceSymbol: product.currencyCode ?? ""
        )
        isPaywallPresented = false
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didFailPurchase product: AdaptyPaywallProduct, error: AdaptyError) {
        guard let paywall = self.paywall else { return }
        analyticsDelegate?.onPurchaseFailed(
            paywallName: paywall.placementId,
            isABTest: paywall.abTestName != paywall.name,
            abTestName: paywall.abTestName,
            productCode: product.vendorProductId,
            errorCode: "\(error.errorCode)",
            errorDetail: error.localizedDescription,
            price: product.price.description,
            priceSymbol: product.currencyCode ?? ""
        )
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didPerform action: AdaptyUI.Action) {
        guard let paywall = self.paywall else { return }
        switch action {
        case .close:
            isPaywallPresented = false
            analyticsDelegate?.onPaywallClose()
        case let .openURL(url):
            UIApplication.shared.open(url, options: [:])
        case .custom:
            break
        }
    }
    
    func paywallControllerDidStartRestore(_ controller: AdaptyPaywallController) {
        // İsteğe bağlı olarak restore başlangıcını işleyebilirsiniz
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didFinishRestoreWith profile: AdaptyProfile) {
        Task {
            do {
                try await restorePurchases()
            } catch {
                AlertKitAPI.present(title: "Premium Not Found!", style: .iOS17AppleMusic, haptic: .error)
            }
        }
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didFailRestoreWith error: AdaptyError) {
        AlertKitAPI.present(title: "Error", style: .iOS17AppleMusic, haptic: .error)
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didFailRenderingWith error: AdaptyError) {
        hidePaywall()
        AlertKitAPI.present(title: error.localizedDescription, style: .iOS17AppleMusic, haptic: .error)
    }
}

// MARK: - View Extension
extension View {
    func adaptyPaywall() -> some View {
        self.modifier(AdaptyPaywallModifier())
    }
}

struct AdaptyPaywallModifier: ViewModifier {
    @StateObject private var adaptyService = AdaptyService.shared
    
    func body(content: Content) -> some View {
        Group {
            if let configuration = adaptyService.paywallConfiguration {
                content.paywall(
                    isPresented: $adaptyService.isPaywallPresented,
                    fullScreen: true,
                    paywallConfiguration: configuration,
                    didPerformAction: { action in
                        if case .close = action {
                            adaptyService.isPaywallPresented = false
                        }
                    },
                    didSelectProduct: { product in
                        print("Selected product: \(product.localizedTitle)")
                    },
                    didStartPurchase: { product in
                        print("Started purchase: \(product.localizedTitle)")
                    },
                    didFinishPurchase: { _, _ in
                        adaptyService.isPaywallPresented = false
                    },
                    didFailPurchase: { product, error in
                        print("Purchase failed: \(error.localizedDescription)")
                    },
                    didStartRestore: {
                        print("Started restore")
                    },
                    didFinishRestore: { _ in
                        Task {
                            do {
                                try await adaptyService.restorePurchases()
                            } catch {
                                AlertKitAPI.present(title: "Premium Not Found!", style: .iOS17AppleMusic, haptic: .error)
                            }
                        }
                    },
                    didFailRestore: { error in
                        AlertKitAPI.present(title: "Error", style: .iOS17AppleMusic, haptic: .error)
                    },
                    didFailRendering: { error in
                        adaptyService.hidePaywall()
                        AlertKitAPI.present(title: error.localizedDescription, style: .iOS17AppleMusic, haptic: .error)
                    }
                )
            } else {
                content
            }
        }
    }
}
