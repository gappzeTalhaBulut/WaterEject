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
    
    var body: some View {
        NavigationHost(title: "dB Meter") {
            VStack(spacing: 20) {
                Spacer()
                
                // Main meter gauge
                ZStack {
                    // Background circle
                    Circle()
                        .trim(from: 0.2, to: 0.8)
                        .stroke(Color(uiColor: .systemGray4), lineWidth: 25)
                        .frame(width: 280, height: 280)
                    
                    // Level indicator
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
                            style: StrokeStyle(lineWidth: 25, lineCap: .round)
                        )
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(36))
                    
                    // Center text
                    VStack {
                        Text(String(format: "%.1f", viewModel.decibels))
                            .font(.system(size: 60, weight: .bold))
                        Text("dB")
                            .font(.title2)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                }
                .padding(.top, 40)
                
                // Stats display with fixed dimensions
                HStack(spacing: 40) {
                    VStack {
                        Text(String(format: "%.1f", viewModel.averageDB))
                            .font(.title2)
                            .frame(width: 60, height: 30)
                        Text("Average")
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                    
                    VStack {
                        Text(String(format: "%.1f", viewModel.minDB))
                            .font(.title2)
                            .frame(width: 60, height: 30)
                        Text("Min")
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                    
                    VStack {
                        Text(String(format: "%.1f", viewModel.maxDB))
                            .font(.title2)
                            .frame(width: 60, height: 30)
                        Text("Max")
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                }
                .padding(.top, 40)
                Spacer()
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.isRecording ? viewModel.stopRecording() : viewModel.startRecording()
                    }) {
                        Text(viewModel.isRecording ? "Stop" : "Start")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(viewModel.isRecording ? Color.red : Color.blue)
                    }
                    .cornerRadius(25)

                    Text("Tap the Start button to begin capturing the sound levels around you.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .onDisappear {
            viewModel.stopRecording()
        }
    }
}

#Preview {
    DBMeterView()
}
