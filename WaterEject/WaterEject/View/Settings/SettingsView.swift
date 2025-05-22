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
            ZStack {
                Color(uiColor: .hgcb)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 32) {
                        if !appStorage.isPremium {
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
                                ModernSettingsRow(icon: "crown.fill", iconColor: .yellow, title: "Get Premium", showArrow: true)
                            }
                            .background(Color(uiColor: .white).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Feedback")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.leading, 16)
                            
                            VStack(spacing: 0) {
                                Button(action: {
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                        SKStoreReviewController.requestReview(in: windowScene)
                                    }
                                }) {
                                    ModernSettingsRow(icon: "star.fill", iconColor: .orange, title: "Rate Us", showArrow: true)
                                }
                                
                                Button(action: { shareApp() }) {
                                    ModernSettingsRow(icon: "square.and.arrow.up", iconColor: .blue, title: "Share", showArrow: true)
                                }
                            }
                            .background(Color(uiColor: .white).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Legal")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.leading, 16)
                            
                            VStack(spacing: 0) {
                                Button(action: {
                                    if let url = URL(string: Config.terms) {
                                        openURL(url)
                                    }
                                }) {
                                    ModernSettingsRow(icon: "doc.text.fill", iconColor: .gray, title: "Terms of Use", showArrow: true)
                                }
                                
                                
                                Button(action: {
                                    if let url = URL(string: Config.privacy) {
                                        openURL(url)
                                    }
                                }) {
                                    ModernSettingsRow(icon: "hand.raised.fill", iconColor: .gray, title: "Privacy Policy", showArrow: true)
                                }
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
                                    ModernSettingsRow(icon: "arrow.clockwise", iconColor: .blue, title: "Restore", showArrow: true)
                                }
                                
                                Button(action: {
                                    UIPasteboard.general.string = Config.UDID
                                    AlertKitAPI.present(
                                        title: "User ID Copied!",
                                        style: .iOS17AppleMusic,
                                        haptic: .success)
                                }) {
                                    ModernSettingsRow(icon: "doc.on.doc.fill", iconColor: .gray, title: "User ID", showArrow: true)
                                }
                            }
                            .background(Color(uiColor: .white).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .adaptyPaywall()
    }
}

struct ModernSettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let showArrow: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color(uiColor: .white).opacity(0.1))
    }
}

#Preview {
    SettingsView()
}
