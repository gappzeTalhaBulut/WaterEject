//
//  ContentView.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct WaterEjectView: View {
    @StateObject private var viewModel = WaterEjectViewModel()
    @StateObject private var cleaningProgress = CleaningProgress.shared
    
    var body: some View {
        NavigationHost(title: "Speaker Cleaner") {
            VStack(spacing: 0) {
                SevenDayCleaningView()
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .environmentObject(cleaningProgress)
                
                // Progress indicator
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: viewModel.progress)
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear(duration: 0.1), value: viewModel.progress)
                    
                    VStack {
                        Image(systemName: viewModel.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.1.fill")
                            .font(.system(size: 50))
                            .foregroundColor(viewModel.isPlaying ? .blue : .gray)
                        
                        if !viewModel.currentPhase.isEmpty {
                            Text(viewModel.currentPhase)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: 200, height: 200)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        if viewModel.isPlaying {
                            viewModel.stopSession()
                        } else {
                            viewModel.startWaterEject()
                        }
                    }) {
                        Text(viewModel.isPlaying ? "Stop" : "Start")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(width: 200, height: 50)
                            .background(viewModel.isPlaying ? Color.red : Color.blue)
                            .cornerRadius(25)
                    }
                    
                    Text("Note: This feature is designed to clean water from your speaker. For best results, please repeat several times.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .onAppear {
                // Push notifications için izin isteği
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("Notification permission granted")
                    } else if let error = error {
                        print("Notification permission error: \(error.localizedDescription)")
                    }
                }
                
                // Set system volume to maximum
                let audioSession = AVAudioSession.sharedInstance()
                try? audioSession.setActive(true)
                MPVolumeView.setVolume(1.0)
            }
        }
    }
}

#Preview {
    WaterEjectView()
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        slider?.value = volume
    }
}
