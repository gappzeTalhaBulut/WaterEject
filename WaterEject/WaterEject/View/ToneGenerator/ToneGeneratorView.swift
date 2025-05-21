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
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var buttonWidth: CGFloat {
        isPad ? 300 : 200
    }
    
    private var buttonHeight: CGFloat {
        isPad ? 60 : 50
    }
    
    private var iconSize: CGFloat {
        isPad ? 60 : 40
    }
    
    var body: some View {
        NavigationHost(title: "Tone") {
            ZStack {
                Color(red: 0.06, green: 0.11, blue: 0.19)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: isPad ? 50 : 30) {
                    Spacer()
                    
                    HStack(spacing: isPad ? 15 : 10) {
                        VStack(spacing: 8) {
                            Image("arrow-up")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(uiColor: .cardBackground))
                            
                            Image("arrow-back")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(uiColor: .cardBackground))
                        }
                        
                        Text("\(Int(viewModel.currentFrequency))")
                            .font(.system(size: isPad ? 120 : 80, weight: .bold))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        
                        Text("hz")
                            .font(.system(size: isPad ? 40 : 30, weight: .bold))
                            .foregroundColor(Color(uiColor: .textColor))
                            .offset(y: isPad ? 50 : 35)
                    }
                    
                    Text("~ Loud like a motorcycle revving.")
                        .font(isPad ? .title3 : .body)
                        .foregroundColor(.gray)
                    
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: isPad ? 120 : 80)
                        
                        SineWaveView(
                            frequency: viewModel.currentFrequency,
                            color: Color(uiColor: .primary),
                            viewModel: viewModel
                        )
                    }
                    .clipShape(Rectangle())
                    
                    Text("This feature is designed to clean water from your speaker.\nFor best results, please repeat several times.")
                        .font(isPad ? .body : .caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                    
                    Spacer()

                    Button(action: {
                        viewModel.togglePlayback()
                    }) {
                        Text(viewModel.isPlaying ? "Stop" : "Play Tone")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(Color(uiColor: .activeCTA))
                            .cornerRadius(16)
                            .padding(.horizontal, 10)
                    }
                    .padding(.bottom, isPad ? 40 : 20)
                }
                .padding(.horizontal, isPad ? 40 : 20)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            let delta = value.translation.height
                            state = delta
                            viewModel.updateFrequency(withDelta: -delta)
                        }
                )
            }
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
