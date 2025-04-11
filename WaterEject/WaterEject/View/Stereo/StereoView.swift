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
    @State private var currentAutoTuneState = 0 // 0: both, 1: left, 2: right
    
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
    
    var body: some View {
        NavigationHost(title: "Stereo Test") {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    // Hoparlör durumu
                    HStack(spacing: 100) {
                        // Sol hoparlör durum metni
                        Text(isLeftSpeakerActive ? "On" : "Off")
                            .foregroundColor(isLeftSpeakerActive ? .blue : .gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isLeftSpeakerActive ? Color.blue : Color.gray, lineWidth: 1)
                            )
                        
                        // Sağ hoparlör durum metni
                        Text(isRightSpeakerActive ? "On" : "Off")
                            .foregroundColor(isRightSpeakerActive ? .blue : .gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isRightSpeakerActive ? Color.blue : Color.gray, lineWidth: 1)
                            )
                    }
                    .padding(.top)
                    
                    // Hoparlör ikonları
                    HStack(spacing: 60) {
                        // Sol hoparlör
                        SpeakerView(isActive: isLeftSpeakerActive, isFlipped: false) {
                            isLeftSpeakerActive.toggle()
                            audioEngine.toggleLeftChannel(isActive: isLeftSpeakerActive)
                        }
                        
                        // Sağ hoparlör
                        SpeakerView(isActive: isRightSpeakerActive, isFlipped: true) {
                            isRightSpeakerActive.toggle()
                            audioEngine.toggleRightChannel(isActive: isRightSpeakerActive)
                        }
                    }
                    
                    // Kanal isimleri
                    HStack(spacing: 60) {
                        Text("Left Channel")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                        
                        Text("Right Channel")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                    }
                    
                    // Auto Tune Toggle
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Auto Tune")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { isAutoTuneEnabled },
                                set: { newValue in
                                    isAutoTuneEnabled = newValue
                                    if newValue {
                                        // AutoTune açıldığında ve ses çalıyorsa timer'ı başlat
                                        if isPlaying {
                                            startAutoTune()
                                        }
                                    } else {
                                        // AutoTune kapatıldığında timer'ı durdur
                                        stopAutoTune()
                                    }
                                }
                            ))
                        }
                        Text("Cycle of alternating playback: both, left, right")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            if isPlaying {
                                audioEngine.stopPlayback()
                                stopAutoTune()
                            } else {
                                audioEngine.playWavFile(named: "music1")
                                if isAutoTuneEnabled {
                                    startAutoTune()
                                }
                            }
                            isPlaying.toggle()
                        }) {
                            Text(isPlaying ? "Stop" : "Start")
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(width: 200, height: 50)
                                .background(isPlaying ? Color.red : Color.blue)
                                .cornerRadius(25)
                        }

                        Text("Toggle the speakers to check if your device's stereo system is working properly. Enable Auto Tune for automatic channel switching.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
        }
        .onDisappear {
            stopAutoTune()
        }
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
