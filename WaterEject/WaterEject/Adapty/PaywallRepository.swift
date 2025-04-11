//
//  PaywallRepository.swift
//  WaterEject
//
//  Created by Talha on 10.04.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class PaywallRepository: ObservableObject {
    static let shared = PaywallRepository()
    
    @Published var response = AppOpenResponse()
    
    private let network: NetworkProtocol
    private let paywallService: AdaptyService
    private let appStorage: AppStorageManager
    private let remoteConfig: RemoteConfigProtocol
    
    private var onPaywallCloseAction: (() -> Void)?
    private var onPaywallPurchaseSuccess: (() -> Void)?
    private var onPaywallRestoreSuccess: (() -> Void)?
    private var currentPlacementId: String?
    private var currentAction: AppPaywallAction?
    
    private var cancellables = Set<AnyCancellable>()
    
    // APPLY-CHANGE: Update the init method to use getSharedAdaptyService()
    private init(network: NetworkProtocol = NetworkService(),
                 paywallService: AdaptyService? = nil,
                 appStorage: AppStorageManager = AppStorageManager(),
                 remoteConfig: RemoteConfigProtocol = RemoteConfigManager.shared) {
        self.network = network
        self.paywallService = paywallService ?? AdaptyService.shared
        self.appStorage = appStorage
        self.remoteConfig = remoteConfig
        self.paywallService.analyticsDelegate = self
    }
    
    func getAppOpenResponse() async -> Bool {
        do {
            let result: AppOpenResponse = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AppOpenResponse, Error>) in
                self.network.request(route: SmartServiceRouter.appOpen)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    } receiveValue: { (response: AppOpenResponse) in
                        debugPrint(response)
                        continuation.resume(returning: response)
                    }
                    .store(in: &self.cancellables)
            }
            
            await MainActor.run {
                debugPrint("Smart Service Fetched Successfully -> \(result)")
                self.response = result
                Config.isAdsActive = result.isAdsActive ?? true
            }
            return result.isPremium
            
        } catch {
            debugPrint("Smart Service Don't fetched -> \(error)")
            return await handleRemoteConfigFallback(error: error)
        }
    }
    
    private func handleRemoteConfigFallback(error: Error) async -> Bool {
        do {
            let result: AppOpenResponse = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AppOpenResponse, Error>) in
                self.remoteConfig.getRemoteConfig { result in
                    switch result {
                    case .success(let response):
                        self.response = response
                        self.remoteConfig.didGetConfig?()
                        continuation.resume(returning: response)
                    case .failure(let error):
                        print("Failed to fetch remote config: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            await MainActor.run {
                self.response = result
                Config.isAdsActive = result.isAdsActive ?? true
            }
            return result.isPremium
        } catch {
           // await handleError(error: error as! NetworkError)
            return false
        }
    }
    
    func checkUser() async -> (isPremium: Bool, originalTransactionId: String) {
        await withCheckedContinuation { continuation in
            paywallService.checkUser { isPremium, originalTransactionId in
                continuation.resume(returning: (isPremium, originalTransactionId))
            }
        }
    }
    
    func restorePurchases(completion: @escaping () -> Void) async {
        onPaywallRestoreSuccess = completion
        try? await paywallService.restorePurchases()
    }
    
    func openPaywallIfEnabled(
        action: AppPaywallAction,
        isNotVisibleAction: (() -> ())? = nil,
        onCloseAction: (() async -> ())? = nil,
        willOpenADS: ((String) -> ())? = nil,
        onPurchaseSuccess: @escaping () -> (),
        onRestoreSuccess: @escaping () -> ()
    ) async {
        guard let paywall = response.actions?.getPaywall(action), paywall.willBeShown else {
            isNotVisibleAction?()
            return
        }
        
        self.currentPlacementId = paywall.placementId
        self.currentAction = action
        self.onPaywallCloseAction = { [weak self] in
            Task { [weak self] in
                await onCloseAction?()
                self?.onPaywallCloseAction = nil
            }
        }
        self.onPaywallPurchaseSuccess = onPurchaseSuccess
        self.onPaywallRestoreSuccess = onRestoreSuccess
        
        do {
            try await paywallService.openPaywall(placementId: paywall.placementId)
        } catch {
            print("Failed to open paywall: \(error)")
            isNotVisibleAction?()
        }
    }
}

// MARK: - AdaptyAnalyticsDelegate
extension PaywallRepository: AdaptyAnalyticsDelegate {
    func onPaywallOpen(paywallName: String, isABTest: Bool, abTestName: String) {
        Task {
            guard let placementId = currentPlacementId,
                  let action = currentAction else { return }
            
         //eventRepository.sendPaywallOpened(
         //    placementId: placementId,
         //    action: action,
         //    paywallName: paywallName,
         //    isABTest: isABTest,
         //    abTestName: abTestName,
         //    unique: Config.UDID,
         //    status: "Success",
         //    errorLog: "nil"
         //)
        }
    }
    
    func onPaywallClose() {
        Task {
            self.onPaywallCloseAction?()
        }
    }
    
    func onPurchaseSuccess(purchaseTransactionId: String,
                          paywallName: String,
                          productId: String,
                          isABTest: Bool,
                          abTestName: String,
                          price: String,
                          priceSymbol: String) {
        Task {
            guard let placementId = currentPlacementId,
                  let action = currentAction else { return }
            
            appStorage.isPremium = true
            
          //  eventRepository.sendPurchaseSuccess(
          //      purchaseTransactionId: purchaseTransactionId,
          //      placementId: placementId,
          //      action: action,
          //      paywallName: paywallName,
          //      isABTest: isABTest,
          //      abTestName: abTestName,
          //      productCode: productId,
          //      unique: Config.UDID,
          //      price: "\(priceSymbol + " " + price)")
          //
          //  eventRepository.sendPurchaseWebhook(
          //      price: "\(priceSymbol + " " + price)",
          //      Action: action,
          //      product: productId,
          //      placement: placementId)
            
            onPaywallPurchaseSuccess?()
        }
    }
    
    func onPurchaseFailed(paywallName: String,
                         isABTest: Bool,
                         abTestName: String,
                         productCode: String,
                         errorCode: String,
                         errorDetail: String,
                         price: String,
                         priceSymbol: String) {
        Task {
            guard let placementId = currentPlacementId,
                  let action = currentAction else { return }
            
          // eventRepository.sendPurchaseFailed(
          //     placementId: placementId,
          //     action: action,
          //     paywallName: paywallName,
          //     isABTest: isABTest,
          //     abTestName: abTestName,
          //     productCode: productCode,
          //     errorCode: errorCode,
          //     errorDetail: errorDetail,
          //     unique: Config.UDID
          // )
        }
    }
    
    func onRestoreSuccess() {
        Task {
            appStorage.isPremium = true
            onPaywallRestoreSuccess?()
        }
    }
}
