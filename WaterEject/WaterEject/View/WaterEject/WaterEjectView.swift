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
        isPad ? 400 : viewModel.isPlaying ? 240 : 200
    }
    
    private var iconSize: CGFloat {
        isPad ? 140 : viewModel.isPlaying ? 140 : 86
    }
    
    var body: some View {
        NavigationHost(title: "Cleaner") {
            VStack(spacing: 12) {
                SevenDayCleaningView()
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .environmentObject(cleaningProgress)
                
                WaterEjectModeView {
                    if viewModel.isPlaying {
                        viewModel.stopSession()
                    } else {
                        viewModel.startWaterEject()
                    }
                }
                .padding(.horizontal)
                .opacity(viewModel.isPlaying ? 0 : 1)
                .animation(.easeInOut, value: viewModel.isPlaying)
                
                if viewModel.isPlaying {
                    Button {
                        viewModel.stopSession()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: isPad ? 30 : 20)
                                .opacity(0.3)
                                .foregroundColor(Color(uiColor: .premium).opacity(0.3))
                            
                            Circle()
                                .trim(from: 0.0, to: viewModel.progress)
                                .stroke(style: StrokeStyle(lineWidth: isPad ? 30 : 20, lineCap: .round, lineJoin: .round))
                                .foregroundColor(Color(uiColor: .premium))
                                .rotationEffect(Angle(degrees: 270.0))
                                .animation(.linear(duration: 0.1), value: viewModel.progress)
                            
                            Image("drop")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: iconSize, height: iconSize)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: circleSize, height: circleSize)
                    .padding(.top, isPad ? 60 : 20)
                    .padding(.bottom, isPad ? 120 : 40)
                } else {
                    Button {
                        viewModel.startWaterEject()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(Color(uiColor: .primary).opacity(0.1), lineWidth: 1)
                                .frame(width: circleSize + 60, height: circleSize + 60)
                            
                            Circle()
                                .stroke(Color(uiColor: .primary).opacity(0.15), lineWidth: 1)
                                .frame(width: circleSize + 40, height: circleSize + 40)
                            
                            Circle()
                                .stroke(Color(uiColor: .primary).opacity(0.2), lineWidth: 1)
                                .frame(width: circleSize + 20, height: circleSize + 20)
                            
                            Circle()
                                .fill(Color(uiColor: .activeCTA))
                                .frame(width: circleSize, height: circleSize)
                            
                            VStack(spacing: 8) {
                                Image("drop")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize, height: iconSize)
                                    .foregroundColor(.white)
                                
                                Text("Start\nCleaning")
                                    .font(.system(size: 20, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.vertical, isPad ? 60 : 20)
                }
                Spacer()
                
                Text("Note: This feature is designed to clean water from your speaker. For best results, please repeat several times.")
                    .font(isPad ? .body : .caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .padding(.horizontal, isPad ? 60 : 20)
                    .padding(.bottom)
                
                
            }
            .background(Color(uiColor: .background))
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("Notification permission granted")
                    } else if let error = error {
                        print("Notification permission error: \(error.localizedDescription)")
                    }
                }
                
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
