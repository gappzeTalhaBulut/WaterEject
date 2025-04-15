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
    private let paywallRepository = PaywallRepository.shared
    
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
                        guard let url = URL(string: "https://apps.apple.com/app/id123456789") else { return }
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }) {
                        Label("Rate Us", systemImage: "star.fill")
                    }
                    
                    Button(action: {
                        guard let url = URL(string: "https://apps.apple.com/app/id123456789") else { return }
                        let activityVC = UIActivityViewController(
                            activityItems: ["Check out this awesome app!", url],
                            applicationActivities: nil
                        )
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            activityVC.popoverPresentationController?.sourceView = rootVC.view
                            rootVC.present(activityVC, animated: true)
                        }
                    }) {
                        Label("Share App", systemImage: "square.and.arrow.up")
                    }
                }
                
                Section {
                    Button(action: {
                        if let url = URL(string: Config.privacy) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    Button(action: {
                        if let url = URL(string: Config.terms) {
                            UIApplication.shared.open(url)
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
