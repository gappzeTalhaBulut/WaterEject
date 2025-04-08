//
//  SplashView.swift
//  WaterEject
//
//  Created by Talha on 8.04.2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.7
    @State private var opacity = 0.5
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if isActive {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        } else {
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
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.bottom, 50)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
