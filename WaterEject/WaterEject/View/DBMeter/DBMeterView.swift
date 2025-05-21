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
    @State private var showCustomPermissionAlert = false
    @State private var microphonePermissionStatus = AVAudioSession.sharedInstance().recordPermission
    
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
                        Circle()
                            .stroke(Color(uiColor: .cardBackground).opacity(0.7), lineWidth: isPad ? 35 : 25)
                            .frame(width: gaugeSize, height: gaugeSize)
                        
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
                    
                    Button(action: {
                        if microphonePermissionStatus == .granted {
                            viewModel.isRecording ? viewModel.stopRecording() : viewModel.startRecording()
                        } else {
                            checkAndRequestPermission()
                        }
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
                if showCustomPermissionAlert {
                    MicrophonePermissionRequestView(
                        onGrantAccess: {
                            showCustomPermissionAlert = false
                            viewModel.requestMicrophonePermission { granted in
                                self.microphonePermissionStatus = AVAudioSession.sharedInstance().recordPermission
                                if granted {
                                }
                            }
                        },
                        onCancel: {
                            showCustomPermissionAlert = false
                        }
                    )
                }
            }
        }
        .onAppear {
            microphonePermissionStatus = AVAudioSession.sharedInstance().recordPermission
            if microphonePermissionStatus == .undetermined {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showCustomPermissionAlert = true
                }
            }
        }
        .onDisappear {
            viewModel.stopRecording()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Allow Microphone Access"),
                message: Text(viewModel.errorMessage ?? "To play tones and eject water, we need access to your microphone. Don't worry — we never record or store any audio."),
                primaryButton: .default(Text("Grant Access")) {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }

    private func checkAndRequestPermission() {
        microphonePermissionStatus = AVAudioSession.sharedInstance().recordPermission
        switch microphonePermissionStatus {
        case .denied:
            viewModel.showAlert = true
        case .granted:
            viewModel.isRecording ? viewModel.stopRecording() : viewModel.startRecording()
        case .undetermined:
            viewModel.showAlert = true
        @unknown default:
            viewModel.showAlert = true
            viewModel.errorMessage = "An unknown error occurred with microphone permissions."
        }
    }
}

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
