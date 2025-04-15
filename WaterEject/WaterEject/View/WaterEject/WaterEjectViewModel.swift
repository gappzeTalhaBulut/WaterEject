//
//  WaterEjectViewModel.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import Foundation
import UIKit

class WaterEjectViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0.0
    @Published var currentPhase = ""
    @Published var showPaywall = false
    
    private let audioEngine = AudioEngine()
    private let appStorage: AppStorageManager
    private let cleaningProgress: CleaningProgress
    private let paywallRepository = PaywallRepository.shared
    private var progressTimer: Timer?
    private var premiumCheckTimer: Timer?
    
    init(appStorage: AppStorageManager = AppStorageManager(),
         cleaningProgress: CleaningProgress = .shared) {
        self.appStorage = appStorage
        self.cleaningProgress = cleaningProgress
        
        audioEngine.onPlaybackComplete = { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.progress = 0.0
                self?.currentPhase = ""
            }
        }
    }
    
    func startWaterEject() {
        guard !isPlaying else { return }
        
        isPlaying = true
        progress = 0.0
        currentPhase = "Starting cleaning..."
        
        // Premium check timer
        premiumCheckTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.checkPremiumAndContinue()
        }
        
        // More gradual frequency changes with overlap
        let frequencies: [(Float, TimeInterval)] = [
            (165, 8.0),  // Low frequency start
            (200, 8.0),  // Gradual increase
            (235, 8.0),  // Mid-low frequency
            (280, 8.0),  // Mid frequency
            (320, 8.0),  // Mid-high frequency
            (380, 8.0),  // Higher
            (440, 8.0),  // Peak frequency
            (380, 8.0),  // Gradual decrease
            (320, 8.0),  // Back down
            (280, 8.0),  // Continue down
            (235, 8.0),  // Almost done
            (165, 8.0)   // Final sweep
        ]
        
        // Total duration is now 96 seconds
        startProgressTimer(totalDuration: 96.0)
        audioEngine.playFrequenciesSequence(frequencies: frequencies)
    }
    
    private func checkPremiumAndContinue() {
        if !appStorage.isPremium {
            stopSession()
            Task {
                await showPaywallForUser()
            }
        }
    }
    
    private func showPaywallForUser() async {
        await paywallRepository.openPaywallIfEnabled(
            action: .cleanAction,
            isNotVisibleAction: nil,
            onCloseAction: nil,
            willOpenADS: nil,
            onPurchaseSuccess: { [weak self] in
                self?.startWaterEject()
            },
            onRestoreSuccess: { [weak self] in
                self?.startWaterEject()
            }
        )
    }
    
    private func startProgressTimer(totalDuration: TimeInterval) {
        progressTimer?.invalidate()
        let interval = 0.1
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.progress += interval / totalDuration
            
            // Update phase description
            if self.progress < 0.25 {
                self.currentPhase = "Low frequency cleaning..."
            } else if self.progress < 0.5 {
                self.currentPhase = "Mid frequency cleaning..."
            } else if self.progress < 0.75 {
                self.currentPhase = "High frequency cleaning..."
            } else {
                self.currentPhase = "Final phase..."
            }
            
            if self.progress >= 1.0 {
                self.cleaningCompleted()
                self.stopSession()
            }
        }
    }
    
    private func cleaningCompleted() {
        cleaningProgress.markDayAsCompleted()
    }
    
    func stopSession() {
        progressTimer?.invalidate()
        progressTimer = nil
        premiumCheckTimer?.invalidate()
        premiumCheckTimer = nil
        isPlaying = false
        progress = 0.0
        currentPhase = ""
        audioEngine.stopPlayback()
    }
    
    deinit {
        progressTimer?.invalidate()
        premiumCheckTimer?.invalidate()
    }
}
