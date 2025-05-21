//
//  StereoView.swift
//  WaterEject
//
//  Created by Talha on 8.04.2025.
//

import SwiftUI
import AVFoundation

struct StereoView: View {
    @StateObject private var audioEngine = AudioEngine()
    @State private var isLeftSpeakerActive = true
    @State private var isRightSpeakerActive = true
    @State private var isPlaying = false
    @State private var isAutoTuneEnabled = false
    @State private var autoTuneTimer: Timer?
    @State private var currentAutoTuneState = 0
    @State private var premiumCheckTimer: Timer?
    
    private let appStorage = AppStorageManager()
    private let paywallRepository = PaywallRepository.shared
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationHost(title: "Stereo") {
            ZStack {
                Color(red: 0.06, green: 0.11, blue: 0.19)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Speaker Controls
                    HStack(spacing: 20) {
                        // Left Speaker Column
                        VStack(spacing: 12) {
                            Button(action: {
                                isLeftSpeakerActive.toggle()
                                audioEngine.toggleLeftChannel(isActive: isLeftSpeakerActive)
                            }) {
                                Text(isLeftSpeakerActive ? "On" : "Off")
                                    .foregroundColor(.white)
                                    .frame(width: 80)
                                    .padding(.vertical, 8)
                                    .background(Color(uiColor: .activeCTA).opacity(isLeftSpeakerActive ? 1 : 0))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(uiColor: .cardBorder), lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                                isLeftSpeakerActive.toggle()
                                audioEngine.toggleLeftChannel(isActive: isLeftSpeakerActive)
                            }) {
                                Image(systemName: "hifispeaker")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 179)
                                    .foregroundColor(isLeftSpeakerActive ? .white : .gray)
                            }
                            
                            Text("Left")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(Color(red: 0.12, green: 0.18, blue: 0.25))
                                .cornerRadius(16)
                        }
                        
                        Spacer()
                        
                        // Right Speaker Column
                        VStack(spacing: 12) {
                            Button(action: {
                                isRightSpeakerActive.toggle()
                                audioEngine.toggleRightChannel(isActive: isRightSpeakerActive)
                            }) {
                                Text(isRightSpeakerActive ? "On" : "Off")
                                    .foregroundColor(.white)
                                    .frame(width: 80)
                                    .padding(.vertical, 8)
                                    .background(Color(uiColor: .activeCTA).opacity(isRightSpeakerActive ? 1 : 0))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(uiColor: .cardBorder), lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                                isRightSpeakerActive.toggle()
                                audioEngine.toggleRightChannel(isActive: isRightSpeakerActive)
                            }) {
                                Image(systemName: "hifispeaker")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 179)
                                    .foregroundColor(isRightSpeakerActive ? .white : .gray)
                            }
                            
                            Text("Right")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(Color(red: 0.12, green: 0.18, blue: 0.25))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // Auto Tune Toggle
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Auto Tune")
                                .foregroundColor(.white)
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { isAutoTuneEnabled },
                                set: { newValue in
                                    isAutoTuneEnabled = newValue
                                    if newValue {
                                        if isPlaying {
                                            startAutoTune()
                                        }
                                    } else {
                                        stopAutoTune()
                                    }
                                }
                            ))
                            .tint(.blue)
                        }
                        
                        Text("Cycle of alternating playback: both left & right")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    .background(Color(red: 0.12, green: 0.18, blue: 0.25))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // Bottom Content
                    VStack(spacing: 20) {
                        Text("This feature is designed to clean water from your speaker.\nFor best results, please repeat several times.")
                            .font(.system(size: 13, weight: .regular))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(uiColor: .textColor))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 10)
                        
                        Button(action: {
                            if isPlaying {
                                stopPlayback()
                            } else {
                                startPlayback()
                            }
                        }) {
                            Text(isPlaying ? "Stop" : "Stereo Check")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                                .background(Color(uiColor: .activeCTA))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 13)
                    .padding(.bottom, 30)
                }
            }
        }
        .onDisappear {
            stopAutoTune()
            stopPlayback()
        }
    }
    
    private func startAutoTune() {
        // Önce mevcut timer'ı temizle
        autoTuneTimer?.invalidate()
        
        // Her 2 saniyede bir değişecek şekilde ayarla
        autoTuneTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            switch currentAutoTuneState {
            case 0: // both -> left
                isLeftSpeakerActive = true
                isRightSpeakerActive = false
                audioEngine.toggleLeftChannel(isActive: true)
                audioEngine.toggleRightChannel(isActive: false)
                currentAutoTuneState = 1
            case 1: // left -> right
                isLeftSpeakerActive = false
                isRightSpeakerActive = true
                audioEngine.toggleLeftChannel(isActive: false)
                audioEngine.toggleRightChannel(isActive: true)
                currentAutoTuneState = 2
            case 2: // right -> both
                isLeftSpeakerActive = true
                isRightSpeakerActive = true
                audioEngine.toggleLeftChannel(isActive: true)
                audioEngine.toggleRightChannel(isActive: true)
                currentAutoTuneState = 0
            default:
                break
            }
        }
    }
    
    private func stopAutoTune() {
        autoTuneTimer?.invalidate()
        autoTuneTimer = nil
    }
    
    private func startPlayback() {
        audioEngine.playWavFile(named: "music1")
        if isAutoTuneEnabled {
            startAutoTune()
        }
        isPlaying = true
        
        // Premium check timer - 3 seconds
        premiumCheckTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            checkPremiumAndContinue()
        }
    }
    
    private func stopPlayback() {
        audioEngine.stopPlayback()
        stopAutoTune()
        premiumCheckTimer?.invalidate()
        premiumCheckTimer = nil
        isPlaying = false
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
            onPurchaseSuccess: {
                startPlayback()
            },
            onRestoreSuccess: {
                startPlayback()
            }
        )
    }
}

struct SpeakerView: View {
    let isActive: Bool
    let isFlipped: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "speaker.wave.3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(isActive ? .blue : .gray)
                .scaleEffect(x: isFlipped ? -1 : 1, y: 1) // Sağ hoparlör için yatay çevirme
        }
    }
}

#Preview {
    StereoView()
}
