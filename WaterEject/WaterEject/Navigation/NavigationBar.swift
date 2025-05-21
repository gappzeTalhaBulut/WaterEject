//
//  NavigationHost.swift
//  WaterEject
//
//  Created by Talha on 14.03.2025.
//

import UIKit
import Foundation
import SwiftUI

struct NavigationHost<Content: View>: View {
    @State private var showingSettings = false
    @State private var isPaywallVisible = false
    @StateObject private var appStorage = AppStorageManager()
    private let paywall: PaywallRepository = .shared
    private let navigationManager : NavigationManager = .shared
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text(title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(uiColor: .titleColor))
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 10) {
                            if !appStorage.isPremium {
                                Button(action: {
                                    Task {
                                        isPaywallVisible = true
                                        await paywall.openPaywallIfEnabled(
                                            action: .premium,
                                            isNotVisibleAction: {
                                                withAnimation {
                                                    isPaywallVisible = false
                                                }
                                            },
                                            onCloseAction: {
                                                withAnimation {
                                                    isPaywallVisible = false
                                                }
                                            },
                                            onPurchaseSuccess: {
                                                withAnimation {
                                                    isPaywallVisible = false
                                                }
                                            },
                                            onRestoreSuccess: {
                                                withAnimation {
                                                    isPaywallVisible = false
                                                }
                                            }
                                        )
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image("pre")
                                            .font(.system(size: 17, weight: .heavy))
                                        Text("Get PRO")
                                            .font(.system(size: 17, weight: .heavy))
                                            .foregroundColor(Color(uiColor: .titleColor))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color(uiColor: .premium))
                                    .cornerRadius(20)
                                }
                            }
                            
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gear")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color(uiColor: .titleColor))
                                    .rotationEffect(.degrees(-30))
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
        }
    }
}
