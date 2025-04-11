//
//  OnboardingView.swift
//  WaterEject
//
//  Created by Talha on 8.04.2025.
//

import Foundation
import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
}

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "onboarding-1",
            title: "Test Your Speaker & Measure Sound Levels",
            description: "Remove trapped water and restore clear sound instantly."
        ),
        OnboardingPage(
            image: "onboarding-2",
            title: "Discover the Power of Frequency",
            description: "Generate sound waves from 0Hz to 22,000Hz for testing & tuning."
        ),
        OnboardingPage(
            image: "onboarding-3",
            title: "Measure Sound Around You",
            description: "Use the dB meter to check noise levels in your environment."
        )
    ]
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 20) {
                        Image(pages[index].image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 420, height: 420)
                            .padding(.top, 60)
                        
                        Text(pages[index].title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text(pages[index].description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack {
                Spacer()
                
                Button(action: {
                    if currentPage == pages.count - 1 {
                        completedOnboarding()
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func completedOnboarding() {
        hasCompletedOnboarding = true
        
        // Önce paywall göster
        Task {
            await PaywallRepository.shared.openPaywallIfEnabled(
                action: .onboarding,
                isNotVisibleAction: {
                    // Paywall gösterilmeyecekse direkt ana ekrana geç
                    navigateToHome()
                },
                onCloseAction: {
                    // Paywall kapatılırsa ana ekrana geç
                    navigateToHome()
                },
                onPurchaseSuccess: {
                    // Başarılı satın alma sonrası ana ekrana geç
                    navigateToHome()
                },
                onRestoreSuccess: {
                    // Başarılı restore sonrası ana ekrana geç
                    navigateToHome()
                }
            )
        }
    }
    
    private func navigateToHome() {
        navigationManager.navigate(to: .home)
    }
}

#Preview {
    OnboardingView()
}
