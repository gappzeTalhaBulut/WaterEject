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
        isPad ? 400 : 280
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
            VStack(spacing: isPad ? 40 : 20) {
                Spacer()
                
                // Main meter gauge
                ZStack {
                    Circle()
                        .trim(from: 0.2, to: 0.8)
                        .stroke(Color(uiColor: .systemGray4), lineWidth: isPad ? 35 : 25)
                        .frame(width: gaugeSize, height: gaugeSize)
                    
                    Circle()
                        .trim(from: 0.2, to: viewModel.gaugeValue)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color(uiColor: .systemBlue),
                                    Color(uiColor: .systemGreen),
                                    Color(uiColor: .systemYellow),
                                    Color(uiColor: .systemOrange),
                                    Color(uiColor: .systemRed)
                                ]),
                                center: .center,
                                startAngle: .degrees(72),
                                endAngle: .degrees(288)
                            ),
                            style: StrokeStyle(lineWidth: isPad ? 35 : 25, lineCap: .round)
                        )
                        .frame(width: gaugeSize, height: gaugeSize)
                        .rotationEffect(.degrees(36))
                    
                    VStack {
                        Text(String(format: "%.1f", viewModel.decibels))
                            .font(.system(size: isPad ? 90 : 60, weight: .bold))
                        Text("dB")
                            .font(isPad ? .title : .title2)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                }
                .padding(.top, isPad ? 60 : 40)
                
                HStack(spacing: isPad ? 60 : 40) {
                    VStack {
                        Text(String(format: "%.1f", viewModel.averageDB))
                            .font(statsFont)
                            .frame(width: isPad ? 90 : 60, height: isPad ? 45 : 30)
                        Text("Average")
                            .font(isPad ? .body : .caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                    
                    VStack {
                        Text(String(format: "%.1f", viewModel.minDB))
                            .font(statsFont)
                            .frame(width: isPad ? 90 : 60, height: isPad ? 45 : 30)
                        Text("Min")
                            .font(isPad ? .body : .caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                    
                    VStack {
                        Text(String(format: "%.1f", viewModel.maxDB))
                            .font(statsFont)
                            .frame(width: isPad ? 90 : 60, height: isPad ? 45 : 30)
                        Text("Max")
                            .font(isPad ? .body : .caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                }
                .padding(.top, isPad ? 60 : 40)
                
                Spacer()
                
                VStack(spacing: isPad ? 24 : 16) {
                    Button(action: {
                        viewModel.isRecording ? viewModel.stopRecording() : viewModel.startRecording()
                    }) {
                        Text(viewModel.isRecording ? "Stop" : "Start")
                            .font(isPad ? .title2 : .headline)
                            .foregroundColor(.white)
                            .frame(width: buttonWidth, height: buttonHeight)
                            .background(viewModel.isRecording ? Color.red : Color.blue)
                            .cornerRadius(buttonHeight / 2)
                    }

                    Text("Tap the Start button to begin capturing the sound levels around you.")
                        .font(isPad ? .body : .caption)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .padding(.horizontal, isPad ? 60 : 20)
                }
                .padding(.bottom, isPad ? 40 : 20)
            }
        }
        .onDisappear {
            viewModel.stopRecording()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Microphone Access Required"),
                message: Text(viewModel.errorMessage ?? "Unknown error occurred"),
                primaryButton: .default(Text("Open Settings")) {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
}

#Preview {
    DBMeterView()
}
