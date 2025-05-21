//
//  DBMeterView.swift
//  WaterEject
//
//  Created by Talha on 14.03.2025.
//

import Foundation
import SwiftUI
import AVFoundation

struct DBMeterView: View {
    @StateObject private var viewModel = DBMeterViewModel()
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var gaugeSize: CGFloat {
        isPad ? 400 : 260
    }
    
    private var buttonWidth: CGFloat {
        isPad ? 300 : 200
    }
    
    private var buttonHeight: CGFloat {
        isPad ? 60 : 50
    }
    
    private var statsFont: Font {
        isPad ? .title : .title2
    }
    
    var body: some View {
        NavigationHost(title: "dB Meter") {
            ZStack {
                Color(red: 0.06, green: 0.11, blue: 0.19)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    ZStack {
                        // Background circle - full ring
                        Circle()
                            .stroke(Color(uiColor: .cardBackground).opacity(0.3), lineWidth: isPad ? 35 : 25)
                            .frame(width: gaugeSize, height: gaugeSize)
                        
                        // Progress circle with gradient - only show if there's sound
                        Circle()
                            .trim(from: 0.0, to: min(1.0, CGFloat(viewModel.decibels / 120.0)))
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        .blue,
                                        .green,
                                        .yellow,
                                        .orange,
                                        .red,
                                        .purple,
                                        .blue
                                    ]),
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(360)
                                ),
                                style: StrokeStyle(lineWidth: isPad ? 35 : 25, lineCap: .round)
                            )
                            .frame(width: gaugeSize, height: gaugeSize)
                            .rotationEffect(.degrees(-90))
                        
                        // Center values
                        VStack(spacing: 4) {
                            Text("\(Int(viewModel.decibels))")
                                .font(.system(size: isPad ? 90 : 60, weight: .bold))
                                .foregroundColor(.white)
                            Text("dB")
                                .font(.system(size: isPad ? 24 : 20))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 35)
                    
                    Spacer()
                    
                    // Stats row
                    HStack(spacing: 30) {
                        StatView(title: "Avg", value: viewModel.averageDB)
                        StatView(title: "Min", value: viewModel.minDB)
                        StatView(title: "Max", value: viewModel.maxDB)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    Text("This feature is designed to clean water from your speaker.\nFor best results, please repeat several times.")
                        .font(.system(size: 13, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(uiColor: .textColor))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 30)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Start button
                    Button(action: {
                        viewModel.isRecording ? viewModel.stopRecording() : viewModel.startRecording()
                    }) {
                        Text(viewModel.isRecording ? "Stop" : "Start Meter")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(Color(uiColor: .activeCTA))
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onDisappear {
            viewModel.stopRecording()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Allow Microphone Access"),
                message: Text("To play tones and eject water, we need access to your microphone. Don't worry — we never record or store any audio."),
                primaryButton: .default(Text("Grant Access")) {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
}

// Stat komponenti
struct StatView: View {
    let title: String
    let value: Double
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            Text(String(format: "%.1f", value))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 100, height: 100)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .cardBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(uiColor: .cardBorder), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

#Preview {
    DBMeterView()
}
