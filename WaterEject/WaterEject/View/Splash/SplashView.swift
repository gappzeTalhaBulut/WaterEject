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
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject private var navigationManager: NavigationManager
    
    private let paywallRepository = PaywallRepository.shared
    
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
            await setup()
        }
        .adaptyPaywall()
    }
    
    private func setup() async {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        
        let isPremium = await paywallRepository.getAppOpenResponse()
        
        if isPremium {
            navigateToHome()
        } else {
            await checkUser()
        }
    }
    
    private func checkUser() async {
        let (isAdaptyPremium, _) = await paywallRepository.checkUser()
        print("Adapty isUserPremium: ", isAdaptyPremium)
        
        if isAdaptyPremium {
            navigateToHome()
        } else {
            if !hasCompletedOnboarding {
                navigateToIntro()
            } else {
                shouldShowPaywall = true
                isPaywallVisible = true
                await openPaywallIfEnabled()
            }
        }
    }
    
    private func openPaywallIfEnabled(action: AppPaywallAction = .frunAction) async {
        await paywallRepository.openPaywallIfEnabled(
            action: action,
            isNotVisibleAction: {
                dismissPaywall()
            },
            onCloseAction: {
                dismissPaywall()
            },
            onPurchaseSuccess: {
                dismissPaywall()
            },
            onRestoreSuccess: {
                dismissPaywall()
            }
        )
    }
    
    private func navigateToHome() {
        navigationManager.navigate(to: .home)
    }
    
    private func navigateToIntro() {
        navigationManager.navigate(to: .intro)
    }
    
    private func dismissPaywall() {
        DispatchQueue.main.async {
            isPaywallVisible = false
            navigationManager.navigate(to: .home)
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(NavigationManager.shared)
}
