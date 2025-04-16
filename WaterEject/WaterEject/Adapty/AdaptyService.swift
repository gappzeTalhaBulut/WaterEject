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
    @Published private(set) var viewConfiguration: AdaptyUI.Configuration?
    
    private init() {}
    
    // MARK: - Public Methods
    func initializeAdapty() async throws {
        try await Adapty.activate("public_live_tDlH2mi6.cOn07VaOAVOZUsfQcxDP")
        let adaptyUIConfiguration = AdaptyUI.Configuration(
            mediaCacheConfiguration: .init(
                memoryStorageTotalCostLimit: 100 * 1024 * 1024,
                memoryStorageCountLimit: .max,
                diskStorageSizeLimit: 100 * 1024 * 1024
            )
        )
        try await AdaptyUI.activate(configuration: adaptyUIConfiguration)
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
        await MainActor.run {
            withAnimation(.easeInOut) {
                self.isPaywallPresented = true
            }
        }
        self.analyticsDelegate?.onPaywallOpen(
            paywallName: paywall.name,
            isABTest: paywall.abTestName != paywall.name,
            abTestName: paywall.abTestName
        )
    }
    
    func hidePaywall() {
        print("AdaptyService - hidePaywall called")
        withAnimation(.easeInOut) {
            isPaywallPresented = false
        }
        paywall = nil
        paywallConfiguration = nil
        analyticsDelegate?.onPaywallClose()
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
    
    @MainActor
    func handlePaywallAction(_ action: AdaptyUI.Action, paywall: AdaptyPaywall) {
        switch action {
        case .close:
            hidePaywall()
        case .openURL(let url):
            Task {
                if url.scheme == nil {
                    // URL'de scheme yoksa https ekle
                    if let modifiedUrl = URL(string: "https://\(url.absoluteString)") {
                        await openURL(modifiedUrl)
                    }
                } else {
                    await openURL(url)
                }
            }
        case .custom:
            break
        }
    }
    
    private func openURL(_ url: URL) async {
        if await UIApplication.shared.canOpenURL(url) {
            do {
                try await UIApplication.shared.open(url)
            } catch {
                print("Failed to open URL: \(error.localizedDescription)")
            }
        } else {
            print("Cannot open URL: \(url)")
        }
    }
    
    func handlePurchaseSuccess(product: AdaptyPaywallProduct, purchaseResult: AdaptyPurchaseResult, paywall: AdaptyPaywall) {
        if let profile = purchaseResult.profile {
            analyticsDelegate?.onPurchaseSuccess(
                purchaseTransactionId: profile.profileId,
                paywallName: paywall.placementId,
                productId: product.vendorProductId,
                isABTest: paywall.abTestName != paywall.name,
                abTestName: paywall.abTestName,
                price: product.price.description,
                priceSymbol: product.currencyCode ?? ""
            )
            hidePaywall()
        } else {
            analyticsDelegate?.onPurchaseFailed(
                paywallName: paywall.placementId,
                isABTest: paywall.abTestName != paywall.name,
                abTestName: paywall.abTestName,
                productCode: product.vendorProductId,
                errorCode: "",
                errorDetail: "",
                price: product.price.description,
                priceSymbol: product.currencyCode ?? ""
            )
        }
    }
    
    func handlePurchaseFailure(product: AdaptyPaywallProduct, error: AdaptyError, paywall: AdaptyPaywall) {
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
            if let paywall = adaptyService.paywall,
               let configuration = adaptyService.paywallConfiguration {
                content.paywall(
                    isPresented: $adaptyService.isPaywallPresented,
                    fullScreen: true,
                    paywallConfiguration: configuration,
                    didPerformAction: { action in
                        adaptyService.handlePaywallAction(action, paywall: paywall)
                    },
                    didSelectProduct: { product in
                        print("Selected product: \(product.localizedTitle)")
                    },
                    didStartPurchase: { product in
                        print("Started purchase: \(product.localizedTitle)")
                    },
                    didFinishPurchase: { product, purchaseResult in
                        adaptyService.handlePurchaseSuccess(product: product, purchaseResult: purchaseResult, paywall: paywall)
                    },
                    didFailPurchase: { product, error in
                        adaptyService.handlePurchaseFailure(product: product, error: error, paywall: paywall)
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
