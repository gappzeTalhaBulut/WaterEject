//
//  SplashView.swift
//  WaterEject
//
//  Created by Talha on 8.04.2025.
//

import SwiftUI

struct SplashView: View {
    @State private var size = 0.7
    @State private var opacity = 0.5
    @State private var isLoading = true
    @State private var shouldShowPaywall = false
    @State private var isPaywallVisible = false
    @State private var didAttemptSetup = false
    
    @EnvironmentObject private var navigationManager: NavigationManager
    
    private let paywallRepository = PaywallRepository.shared
    private let appStorage = AppStorageManager()
    private let remoteConfig = RemoteConfigManager.shared
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Image("splash-1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundColor(.clear)
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 1.0
                            self.opacity = 1.0
                        }
                    }
                
                Spacer()
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.bottom, 50)
                }
            }
        }
        .task {
            if !didAttemptSetup {
                didAttemptSetup = true
                await setup()
            }
        }
        .adaptyPaywall()
        .onChange(of: isPaywallVisible) { newValue in
            print("SplashView - isPaywallVisible changed to: \(newValue)")
        }
    }
    
    private func checkWhereToStart() async {
        let isPremium = await paywallRepository.getAppOpenResponse()
        if !isPremium {
            appStorage.isPremium = true
            navigateToHome()
        } else {
            await checkUser()
        }
    }
    
    private func checkUser() async {
        let (isAdaptyPremium, _) = await paywallRepository.checkUser()
        print("Adapty isUserPremium: ", isAdaptyPremium)
        print("seenIntro değeri: ", self.appStorage.hasCompletedOnboarding)
        appStorage.isPremium = isAdaptyPremium
        GeneralHelper.shared.rateUs()
        
        if isAdaptyPremium {
            navigateToHome()
        } else {
            if !appStorage.hasCompletedOnboarding {
                navigateToIntro()
            } else {
                shouldShowPaywall = true
                isPaywallVisible = true
                await openPaywallIfEnabled()
            }
        }
    }
    
    private func setup() async {
        setupRemoteConfig()
    }
    
    private func setupRemoteConfig() {
        remoteConfig.didGetConfig = { [self] in
            AppConfig.serURL = remoteConfig.string(for: FireBaseRemoteConfigKey.smartServiceURL)
            AppConfig.errorWebhook = remoteConfig.string(for: FireBaseRemoteConfigKey.errorWebhook)
            AppConfig.eventService = remoteConfig.string(for: FireBaseRemoteConfigKey.eventsUrl)
            AppConfig.apiKey = remoteConfig.string(for: FireBaseRemoteConfigKey.apiKey)
            AppConfig.proxy = remoteConfig.string(for: FireBaseRemoteConfigKey.proxy)
            AppConfig.googleKey = remoteConfig.string(for: FireBaseRemoteConfigKey.googleKey)
            AppConfig.webhookService = remoteConfig.string(for: FireBaseRemoteConfigKey.webhook)
            AppConfig.normalLimit = remoteConfig.int(for: FireBaseRemoteConfigKey.normalLimit)
            AppConfig.premiumLimit = remoteConfig.int(for: FireBaseRemoteConfigKey.premiumLimit)
            Config.api_key = remoteConfig.string(for: FireBaseRemoteConfigKey.musicKey)
            Config.terms = remoteConfig.string(for: FireBaseRemoteConfigKey.terms)
            Config.privacy = remoteConfig.string(for: FireBaseRemoteConfigKey.privacy)
            
            Task {
                await checkWhereToStart()
            }
        }
    }
    
    private func openPaywallIfEnabled(action: AppPaywallAction = .frunAction) async {
        print("SplashView - openPaywallIfEnabled with action: \(action)")
        
        // Wait a bit to ensure any previous sheets are dismissed
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await paywallRepository.openPaywallIfEnabled(
            action: action,
            isNotVisibleAction: {
                print("SplashView - isNotVisibleAction triggered")
                dismissPaywall()
            },
            onCloseAction: {
                print("SplashView - onCloseAction triggered")
                dismissPaywall()
            },
            onPurchaseSuccess: {
                print("SplashView - onPurchaseSuccess triggered")
                dismissPaywall()
            },
            onRestoreSuccess: {
                print("SplashView - onRestoreSuccess triggered")
                dismissPaywall()
            }
        )
    }
    
    private func navigateToHome() {
        print("SplashView - navigateToHome called")
        DispatchQueue.main.async {
            isLoading = false
            navigationManager.navigate(to: .home)
        }
    }
    
    private func navigateToIntro() {
        navigationManager.navigate(to: .intro)
    }
    
    private func dismissPaywall() {
        print("SplashView - dismissPaywall called")
        isPaywallVisible = false
        navigateToHome()
    }
}

#Preview {
    SplashView()
        .environmentObject(NavigationManager.shared)
}
