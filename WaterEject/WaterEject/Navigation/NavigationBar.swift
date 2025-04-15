//
//  NavigationHost.swift
//  WaterEject
//
//  Created by Talha on 14.03.2025.
//

import Foundation
import SwiftUI

struct NavigationHost<Content: View>: View {
    @State private var showingSettings = false
    @State private var isPaywallVisible = false
    private let paywall: PaywallRepository = .shared
    private let navigationManager : NavigationManager = .shared
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
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
                                Image(systemName: "crown.fill")
                                    .foregroundColor(Color(uiColor: .systemYellow))
                            }
                            
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(Color(uiColor: .label))
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
