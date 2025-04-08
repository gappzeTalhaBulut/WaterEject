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
    
    var body: some View {
        NavigationHost(title: "Stereo Test") {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    // Hoparlör durumu
                    HStack(spacing: 100) {
                        Text(isLeftSpeakerActive ? "On" : "Off")
                            .foregroundColor(isLeftSpeakerActive ? .blue : .gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isLeftSpeakerActive ? Color.blue : Color.gray, lineWidth: 1)
                            )
                        
                        Text(isRightSpeakerActive ? "On" : "Off")
                            .foregroundColor(isRightSpeakerActive ? .blue : .gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isRightSpeakerActive ? Color.blue : Color.gray, lineWidth: 1)
                            )
                    }
                    
                    // Hoparlör ikonları
                    HStack(spacing: 60) {
                        SpeakerView(isActive: isLeftSpeakerActive) {
                            isLeftSpeakerActive.toggle()
                            audioEngine.toggleLeftChannel(isActive: isLeftSpeakerActive)
                        }
                        
                        SpeakerView(isActive: isRightSpeakerActive) {
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
                            Toggle("", isOn: $isAutoTuneEnabled)
                        }
                        Text("Cycle of alternating playback: both, left, right")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // Start/Stop button - WaterEjectView stil ile uyumlu
                    Button(action: {
                        if isPlaying {
                            audioEngine.stopPlayback()
                        } else {
                            audioEngine.playWavFile(named: "music1")
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
                }
                .padding()
            }
        }
    }
}

struct SpeakerView: View {
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "speaker.wave.3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(isActive ? .blue : .gray)
        }
    }
}

#Preview {
    StereoView()
}
