//
//  SettingsView.swift
//  WaterEject
//
//  Created by Talha on 14.03.2025.
//

import Foundation
import SwiftUI
import StoreKit
import AlertKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var appStorage = AppStorageManager()
    private let paywallRepository = PaywallRepository.shared
    
    private func shareApp() {
        guard let url = URL(string: Config.appUrl) else { return }
        let activityVC = UIActivityViewController(
            activityItems: ["Check out this awesome app!", url],
            applicationActivities: nil
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return
            }
            
            var topController = window.rootViewController
            while let presentedVC = topController?.presentedViewController {
                topController = presentedVC
            }
            
            if let topController = topController {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    activityVC.popoverPresentationController?.sourceView = topController.view
                    activityVC.popoverPresentationController?.sourceRect = CGRect(
                        x: UIScreen.main.bounds.width / 2,
                        y: UIScreen.main.bounds.height / 2,
                        width: 0,
                        height: 0
                    )
                    activityVC.popoverPresentationController?.permittedArrowDirections = []
                }
                
                topController.present(activityVC, animated: true)
            }
        }
    }
    
    private func openURL(_ url: URL) {
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        Task {
                            await paywallRepository.openPaywallIfEnabled(
                                action: .premium,
                                isNotVisibleAction: nil,
                                onCloseAction: nil,
                                willOpenADS: nil,
                                onPurchaseSuccess: {},
                                onRestoreSuccess: {}
                            )
                        }
                    }) {
                        HStack {
                            Label("Get Premium", systemImage: "crown.fill")
                                .foregroundColor(Color(uiColor: .systemYellow))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(uiColor: .systemGray4))
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }) {
                        Label("Rate Us", systemImage: "star.fill")
                    }
                    
                    Button(action: {
                        shareApp()
                    }) {
                        Label("Share App", systemImage: "square.and.arrow.up")
                    }
                }
                
                Section {
                    Button(action: {
                        if let url = URL(string: Config.privacy) {
                            openURL(url)
                        }
                    }) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    Button(action: {
                        if let url = URL(string: Config.terms) {
                            openURL(url)
                        }
                    }) {
                        Label("Terms of Use", systemImage: "doc.text.fill")
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            do {
                                try await AdaptyService.shared.restorePurchases()
                            } catch {
                                AlertKitAPI.present(
                                    title: "Premium Not Found!",
                                    style: .iOS17AppleMusic,
                                    haptic: .error)
                                print("Restore failed:", error)
                            }
                        }
                    }) {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                    
                    Button(action: {
                        UIPasteboard.general.string = Config.UDID
                        AlertKitAPI.present(
                            title: "User ID Copied!",
                            style: .iOS17AppleMusic,
                            haptic: .success)
                    }) {
                        Label("User ID", systemImage: "doc.on.doc.fill")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
        }
        .adaptyPaywall()
    }
}

#Preview {
    SettingsView()
}
