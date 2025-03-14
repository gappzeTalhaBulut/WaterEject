//
//  ToneGeneratorView.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import Foundation
import SwiftUI
import AVFoundation

struct ToneGeneratorView: View {
    @StateObject private var viewModel = ToneGeneratorViewModel()
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemBackground).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Volume indicator
                    Image(systemName: "speaker.wave.3")
                        .font(.system(size: 40))
                        .foregroundColor(Color(uiColor: .label))
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(Circle())
                    
                    // Remove duplicate frequency display and add gesture indicator
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.up.and.down.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                        
                        Text("\(Int(viewModel.currentFrequency))")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(viewModel.frequencyColor)
                        
                        Text("hz")
                            .font(.title2)
                            .foregroundColor(viewModel.frequencyColor)
                    }
                    
                    Text("Swipe up & down to\nadjust frequency")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    
                    // Updated wave visualization with proper clipping
                    ZStack {
                        Rectangle()
                            .fill(Color(uiColor: .systemBackground))
                            .frame(height: 80)
                        
                        SineWaveView(
                            frequency: viewModel.currentFrequency,
                            color: viewModel.frequencyColor,
                            viewModel: viewModel
                        )
                    }
                    .clipShape(Rectangle())
                    
                    // Play/Stop button remains the same
                    Button(action: {
                        viewModel.togglePlayback()
                    }) {
                        Text(viewModel.isPlaying ? "Stop playing" : "Start playing")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(uiColor: viewModel.isPlaying ? .systemRed : .systemBlue))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            let delta = value.translation.height
                            state = delta
                            viewModel.updateFrequency(withDelta: -delta)
                        }
                )
            }
            .navigationTitle("Tone Generator")
        }
    }
}

struct SineWaveView: View {
    let frequency: Double
    let color: Color
    @State private var phase: Double = 0
    @ObservedObject var viewModel: ToneGeneratorViewModel
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let midHeight = height / 2
                let amplitude = height / 3.5
                
                if viewModel.isPlaying {
                    let path = Path { path in
                        let x0 = 0.0
                        let relativeX0 = Double(x0) / Double(width)
                        let y0 = midHeight + amplitude * sin(relativeX0 * 2 * .pi * 2 + phase)
                        path.move(to: CGPoint(x: x0, y: y0))
                        
                        for x in stride(from: 1.0, through: width, by: 1.0) {
                            let relativeX = Double(x) / Double(width)
                            let y = midHeight + amplitude * sin(relativeX * 2 * .pi * 2 + phase)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    context.stroke(path, with: .color(color), lineWidth: 3)
                } else {
                    let path = Path { path in
                        path.move(to: CGPoint(x: 0, y: midHeight))
                        path.addLine(to: CGPoint(x: width, y: midHeight))
                    }
                    context.stroke(path, with: .color(color), lineWidth: 3)
                }
            }
        }
        .onReceive(timer) { _ in
            if viewModel.isPlaying {
                withAnimation(.linear(duration: 0.016)) {
                    phase += 0.05
                    if phase > .pi * 2 {
                        phase -= .pi * 2
                    }
                }
            }
        }
    }
}

#Preview {
    ToneGeneratorView()
}
