//
//  ToneGeneratorViewModel.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import Foundation
import SwiftUI
import AVFoundation

class ToneGeneratorViewModel: ObservableObject {
    @Published var currentFrequency: Double = 375
    @Published var isPlaying = false
    
    private let audioEngine = AudioEngine()
    private let minFrequency: Double = 1
    private let maxFrequency: Double = 22000
    private let appStorage: AppStorageManager
    private let paywallRepository = PaywallRepository.shared
    private var premiumCheckTimer: Timer?
    
    init(appStorage: AppStorageManager = AppStorageManager()) {
        self.appStorage = appStorage
    }
    
    // Add color computation
    var frequencyColor: Color {
        let percentage = (currentFrequency - minFrequency) / (maxFrequency - minFrequency)
        return Color(
            red: min(1.0, percentage * 2),
            green: max(0, 1 - percentage * 1.5),
            blue: max(0, 1 - percentage * 2)
        )
    }
    
    func updateFrequency(withDelta delta: CGFloat) {
        let sensitivity: Double = 5.0
        let newFrequency = currentFrequency + Double(delta) * sensitivity
        
        // Update on main thread
        DispatchQueue.main.async {
            self.currentFrequency = min(max(newFrequency, self.minFrequency), self.maxFrequency)
            
            if self.isPlaying {
                self.playCurrentFrequency()
            }
        }
    }
    
    func togglePlayback() {
        DispatchQueue.main.async {
            self.isPlaying.toggle()
            if self.isPlaying {
                self.startPlayback()
            } else {
                self.stopPlayback()
            }
        }
    }
    
    private func startPlayback() {
        playCurrentFrequency()
        
        // Premium check timer - 3 seconds
        premiumCheckTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.checkPremiumAndContinue()
        }
    }
    
    private func checkPremiumAndContinue() {
        if !appStorage.isPremium {
            stopPlayback()
            Task {
                await showPaywallForUser()
            }
        }
    }
    
    private func showPaywallForUser() async {
        await paywallRepository.openPaywallIfEnabled(
            action: .toneAction,
            isNotVisibleAction: nil,
            onCloseAction: nil,
            willOpenADS: nil,
            onPurchaseSuccess: { [weak self] in
                self?.startPlayback()
            },
            onRestoreSuccess: { [weak self] in
                self?.startPlayback()
            }
        )
    }
    
    private func playCurrentFrequency() {
        audioEngine.playFrequency(Float(currentFrequency), duration: 60.0)
    }
    
    func stopPlayback() {
        premiumCheckTimer?.invalidate()
        premiumCheckTimer = nil
        isPlaying = false
        audioEngine.stopPlayback()
    }
    
    deinit {
        stopPlayback()
    }
}
