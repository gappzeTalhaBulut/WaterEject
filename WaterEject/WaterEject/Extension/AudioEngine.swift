//
//  AudioEngine.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioEngine {
    private var engine: AVAudioEngine?
    private var playerNode: AVAudioSourceNode?
    private var currentPhase: Double = 0
    private var currentFrequency: Float = 440
    private var isSetup = false
    private var isPlaying = false
    
    // Added completion handler
    var onPlaybackComplete: (() -> Void)?
    
    // Lazy initialization
    private func setupEngineIfNeeded() {
        guard !isSetup else { return }
        
        do {
            // Configure audio session for maximum volume
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            
            // Set system volume to maximum
            let volumeView = MPVolumeView()
            if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    slider.value = 1.0
                }
            }
            
            engine = AVAudioEngine()
            let mainMixer = engine!.mainMixerNode
            let format = mainMixer.outputFormat(forBus: 0)
            
            // Create source node
            playerNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
                guard let self = self, self.isPlaying else {
                    let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
                    for buffer in ablPointer {
                        let buf = UnsafeMutableBufferPointer<Float>(buffer)
                        for frame in 0..<Int(frameCount) {
                            buf[frame] = 0.0
                        }
                    }
                    return noErr
                }
                
                let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
                let factor = 2.0 * Double.pi * Double(self.currentFrequency)
                
                for frame in 0..<Int(frameCount) {
                    let value = sin(factor * self.currentPhase)
                    self.currentPhase += 1.0 / Double(format.sampleRate)
                    if self.currentPhase >= 1.0 {
                        self.currentPhase -= 1.0
                    }
                    
                    for buffer in ablPointer {
                        let buf = UnsafeMutableBufferPointer<Float>(buffer)
                        buf[frame] = Float(value)
                    }
                }
                return noErr
            }
            
            if let playerNode = self.playerNode {
                engine!.attach(playerNode)
                engine!.connect(playerNode, to: mainMixer, format: format)
                
                do {
                    try engine!.start()
                } catch {
                    print("Could not start engine: \(error)")
                }
            }
            
            isSetup = true
        } catch {
            print("Failed to setup audio engine: \(error)")
        }
    }
    
    init() {
        setupEngineIfNeeded()
    }
    
    func generateSineWave(frequency: Float, duration: TimeInterval) -> AVAudioPCMBuffer? {
        setupEngineIfNeeded()
        
        guard let mainMixer = engine?.mainMixerNode else { return nil }
        
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: mainMixer.outputFormat(forBus: 0),
                                          frameCapacity: frameCount) else { return nil }
        
        buffer.frameLength = frameCount
        
        // Optimize wave generation - use single channel
        if let data = buffer.floatChannelData?[0] {
            let stride = Int(buffer.stride)
            for frame in 0..<Int(frameCount) {
                let value = sin(2.0 * .pi * Double(frequency) * Double(frame) / sampleRate)
                data[frame * stride] = Float(value)
            }
        }
        
        return buffer
    }
    
    func stopPlayback() {
        isPlaying = false
        engine?.stop()
        isSetup = false  // Reset setup flag
        try? AVAudioSession.sharedInstance().setActive(false)
        onPlaybackComplete?()
    }
    
    func playFrequency(_ frequency: Float, duration: TimeInterval = 60.0) {
        setupEngineIfNeeded()
        currentFrequency = frequency
        isPlaying = true
        
        // Remove duration-based stopping
        // The audio will continue until stopPlayback is called
    }
    
    func playFrequenciesSequence(frequencies: [(frequency: Float, duration: TimeInterval)]) {
        guard !isPlaying else { return }
        
        setupEngineIfNeeded()
        isPlaying = true
        
        var accumulatedDelay: TimeInterval = 0
        
        for (frequency, duration) in frequencies {
            currentFrequency = frequency
            
            accumulatedDelay += duration
        }
        
        // Schedule completion
        let totalDuration = frequencies.reduce(0) { $0 + $1.duration }
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) { [weak self] in
            self?.stopPlayback()
        }
    }
    
    deinit {
        stopPlayback()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
