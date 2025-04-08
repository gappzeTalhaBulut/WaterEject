//
//  ToneGeneratorViewModel.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import Foundation
import SwiftUI
import AVFoundation

class ToneGeneratorViewModel: ObservableObject {
    @Published var currentFrequency: Double = 375
    @Published var isPlaying = false
    
    private let audioEngine = AudioEngine()
    private let minFrequency: Double = 1
    private let maxFrequency: Double = 22000
    
    // Add color computation
    var frequencyColor: Color {
        let percentage = (currentFrequency - minFrequency) / (maxFrequency - minFrequency)
        return Color(
            red: min(1.0, percentage * 2),
            green: max(0, 1 - percentage * 1.5),
            blue: max(0, 1 - percentage * 2)
        )
    }
    
    func updateFrequency(withDelta delta: CGFloat) {
        let sensitivity: Double = 5.0
        let newFrequency = currentFrequency + Double(delta) * sensitivity
        
        // Update on main thread
        DispatchQueue.main.async {
            self.currentFrequency = min(max(newFrequency, self.minFrequency), self.maxFrequency)
            
            if self.isPlaying {
                self.playCurrentFrequency()
            }
        }
    }
    
    func togglePlayback() {
        DispatchQueue.main.async {
            self.isPlaying.toggle()
            if self.isPlaying {
                self.playCurrentFrequency()
            } else {
                self.audioEngine.stopPlayback()
            }
        }
    }
    
    private func playCurrentFrequency() {
        audioEngine.playFrequency(Float(currentFrequency), duration: 60.0)
    }
    
    deinit {
        audioEngine.stopPlayback()
    }
}
