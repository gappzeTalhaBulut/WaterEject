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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Su Çıkarma Özelliği")
                    .font(.title)
                    .padding()
                
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
                
                Button(action: {
                    if viewModel.isPlaying {
                        viewModel.stopSession()
                    } else {
                        viewModel.startWaterEject()
                    }
                }) {
                    Text(viewModel.isPlaying ? "Durdur" : "Başlat")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(viewModel.isPlaying ? Color.red : Color.blue)
                        .cornerRadius(25)
                }
                
                Text("Not: Bu özellik %100 garanti vermez. Cihazınızı başka yöntemlerle de kurutmaya çalışın.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
            .onAppear {
                // Set system volume to maximum
                let audioSession = AVAudioSession.sharedInstance()
                try? audioSession.setActive(true)
                MPVolumeView.setVolume(1.0)
            }
            .navigationTitle("Speaker Cleaner")
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
