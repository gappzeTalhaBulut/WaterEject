//
//  WaterEjectApp.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import SwiftUI

@main
struct WaterEjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var navigationManager = NavigationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationManager)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        Group {
            switch navigationManager.currentState {
            case .splash:
                SplashView()
                    .adaptyPaywall()
            case .home:
                MainTabView()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            case .intro:
                OnboardingView()
            case .paywall:
                Color.clear
            case .settings:
                SettingsView()
            }
        }
        .animation(.default, value: navigationManager.currentState)
    }
}
