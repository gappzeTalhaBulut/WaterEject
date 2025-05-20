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
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var circleSize: CGFloat {
        isPad ? 400 : 200
    }
    
    private var buttonWidth: CGFloat {
        isPad ? 300 : 200
    }
    
    private var buttonHeight: CGFloat {
        isPad ? 60 : 50
    }
    
    private var iconSize: CGFloat {
        isPad ? 80 : 50
    }
    
    var body: some View {
        NavigationHost(title: "Cleaner") {
            VStack(spacing: 0) {
                SevenDayCleaningView()
                    .padding(.top)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .environmentObject(cleaningProgress)
                
                // Progress indicator
                ZStack {
                    Circle()
                        .stroke(lineWidth: isPad ? 30 : 20)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: viewModel.progress)
                        .stroke(style: StrokeStyle(lineWidth: isPad ? 30 : 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear(duration: 0.1), value: viewModel.progress)
                    
                    VStack(spacing: isPad ? 20 : 10) {
                        Image(systemName: viewModel.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.1.fill")
                            .font(.system(size: iconSize))
                            .foregroundColor(viewModel.isPlaying ? .blue : .gray)
                        
                        if !viewModel.currentPhase.isEmpty {
                            Text(viewModel.currentPhase)
                                .font(isPad ? .title3 : .caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: circleSize, height: circleSize)
                .padding(.vertical, isPad ? 60 : 20)
                
                Spacer(minLength: 0)
                
                VStack(spacing: isPad ? 24 : 16) {
                    Button(action: {
                        if viewModel.isPlaying {
                            viewModel.stopSession()
                        } else {
                            viewModel.startWaterEject()
                        }
                    }) {
                        Text(viewModel.isPlaying ? "Stop" : "Start")
                            .foregroundColor(.white)
                            .font(isPad ? .title2 : .headline)
                            .frame(width: buttonWidth, height: buttonHeight)
                            .background(viewModel.isPlaying ? Color.red : Color.blue)
                            .cornerRadius(buttonHeight / 2)
                    }
                    
                    Text("Note: This feature is designed to clean water from your speaker. For best results, please repeat several times.")
                        .font(isPad ? .body : .caption)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .padding(.horizontal, isPad ? 60 : 20)
                }
                .padding(.bottom, isPad ? 40 : 20)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.viewModel.requestAppTrackingPermission()
                }
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
