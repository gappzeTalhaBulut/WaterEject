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
    
    var body: some View {
        NavigationHost(title: "Tone") {
            ZStack {
                Color(red: 0.06, green: 0.11, blue: 0.19)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer()
                    // Frequency Display Block
                    VStack(spacing: 5) {
                        HStack(alignment: .lastTextBaseline, spacing: isPad ? 10 : 8) {
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
                            .padding(.trailing, isPad ? 5 : 0)
                            
                            Text("\(Int(viewModel.currentFrequency))")
                                .font(.system(size: isPad ? 120 : 80, weight: .bold))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            
                            Text("hz")
                                .font(.system(size: isPad ? 40 : 30, weight: .bold))
                                .foregroundColor(Color(uiColor: .textColor))
                                .offset(y: isPad ? 15 : 10)
                        }
                        Text("~ Loud like a motorcycle revving.")
                            .font(isPad ? .title3 : .body)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // SineWaveView with enforced small height
                    SineWaveView(
                        frequency: viewModel.currentFrequency,
                        color: Color(uiColor: .primary),
                        viewModel: viewModel
                    )
                    .frame(height: 30) // Enforce small height here
                    
                    Spacer()
                    
                    // Bottom content
                    VStack(spacing: 15) {
                        Text("This feature is designed to clean water from your speaker.\nFor best results, please repeat several times.")
                            .font(.system(size: 13, weight: .regular))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(uiColor: .textColor))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 15)
                        
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
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 13)
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
    
    private func getAmplitudeForFrequency(_ freq: Double) -> Double {
        // Frekans aralığını daha mantıklı bölelim
        let minFreq: Double = 1
        let maxFreq: Double = 22000
        
        // Logaritmik ölçek kullanalım (frekansı daha dengeli dağıtmak için)
        let normalizedFreq = log10(max(freq, 1)) / log10(maxFreq)
        
        // Daha makul değerler kullanalım
        let minDivider: Double = 16  // En düşük dalga boyu
        let maxDivider: Double = 6   // En yüksek dalga boyu
        
        // Linear yerine yumuşak bir geçiş
        let smoothedValue = (1 - cos(normalizedFreq * .pi)) / 2
        return minDivider - (smoothedValue * (minDivider - maxDivider))
    }
    
    private func createWavePath(in size: CGSize, amplitude: Double) -> Path {
        let width = size.width
        let height = size.height
        let midHeight = height / 2
        
        var path = Path()
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        let steps = Int(width)
        for step in 0...steps {
            let x = Double(step)
            let normalizedX = x / width
            let y = midHeight + amplitude * sin(2 * .pi * normalizedX * 2 + phase)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
    
    private func createFlatPath(in size: CGSize) -> Path {
        let midHeight = size.height / 2
        var path = Path()
        path.move(to: CGPoint(x: 0, y: midHeight))
        path.addLine(to: CGPoint(x: size.width, y: midHeight))
        return path
    }
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let divider = getAmplitudeForFrequency(frequency)
                let amplitude = size.height / divider
                
                let path = viewModel.isPlaying ?
                    createWavePath(in: size, amplitude: amplitude) :
                    createFlatPath(in: size)
                
                context.stroke(path, with: .color(color), lineWidth: 2)
            }
        }
        .frame(height: 30)
        .onReceive(timer) { _ in
            if viewModel.isPlaying {
                withAnimation(.linear(duration: 0.016)) {
                    phase += 0.1 // Daha makul bir animasyon hızı
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
