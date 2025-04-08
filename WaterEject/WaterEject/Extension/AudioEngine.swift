//
//  AudioEngine.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import Foundation
import AVFoundation
import MediaPlayer
import Combine

class AudioEngine: ObservableObject {
    @Published private(set) var isPlaying = false
    
    private enum PlaybackMode {
        case none
        case sineWave
        case wavFile
    }
    
    private var engine: AVAudioEngine?
    private var playerNode: AVAudioSourceNode?
    private var wavPlayerNode: AVAudioPlayerNode?
    private var currentPhase: Double = 0
    private var currentFrequency: Float = 440
    private var isSetup = false
    private var currentMode: PlaybackMode = .none
    
    private var leftGain: Float = 1.0
    private var rightGain: Float = 1.0
    
    var onPlaybackComplete: (() -> Void)?
    
    private func resetEngine() {
        engine?.stop()
        engine = nil
        playerNode = nil
        wavPlayerNode = nil
        isSetup = false
        currentMode = .none
    }
    
    private func setupEngineIfNeeded(for mode: PlaybackMode) {
        resetEngine()
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            
            engine = AVAudioEngine()
            let mainMixer = engine!.mainMixerNode
            let format = mainMixer.outputFormat(forBus: 0)
            
            switch mode {
            case .sineWave:
                playerNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
                    guard let self = self,
                          self.isPlaying,
                          self.currentMode == .sineWave else {
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
                        
                        if ablPointer.count >= 2 {
                            let leftBuf = UnsafeMutableBufferPointer<Float>(ablPointer[0])
                            leftBuf[frame] = Float(value) * self.leftGain
                            
                            let rightBuf = UnsafeMutableBufferPointer<Float>(ablPointer[1])
                            rightBuf[frame] = Float(value) * self.rightGain
                        }
                    }
                    return noErr
                }
                
                if let playerNode = playerNode {
                    engine!.attach(playerNode)
                    engine!.connect(playerNode, to: mainMixer, format: format)
                }
                
            case .wavFile:
                wavPlayerNode = AVAudioPlayerNode()
                if let wavPlayerNode = wavPlayerNode {
                    engine!.attach(wavPlayerNode)
                    engine!.connect(wavPlayerNode, to: mainMixer, format: format)
                    wavPlayerNode.volume = 1.0
                    wavPlayerNode.pan = 0.0
                }
                
            case .none:
                break
            }
            
            try engine!.start()
            isSetup = true
            currentMode = mode
            
        } catch {
            print("Failed to setup audio engine: \(error)")
        }
    }
    
    func playFrequency(_ frequency: Float, duration: TimeInterval = 60.0) {
        if !isPlaying {
            setupEngineIfNeeded(for: .sineWave)
        }
        currentFrequency = frequency
        isPlaying = true
    }
    
    func playWavFile(named fileName: String) {
        setupEngineIfNeeded(for: .wavFile)
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: "wav"),
              let wavPlayerNode = wavPlayerNode else {
            print("Could not find wav file or player node")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let file = try AVAudioFile(forReading: url)
            wavPlayerNode.scheduleFile(file, at: nil)
            updatePanning()
            wavPlayerNode.play()
            isPlaying = true
        } catch {
            print("Could not create audio file: \(error)")
        }
    }
    
    func playFrequenciesSequence(frequencies: [(frequency: Float, duration: TimeInterval)]) {
        setupEngineIfNeeded(for: .sineWave)
        isPlaying = true
        
        var accumulatedDelay: TimeInterval = 0
        
        for (frequency, duration) in frequencies {
            DispatchQueue.main.asyncAfter(deadline: .now() + accumulatedDelay) { [weak self] in
                self?.currentFrequency = frequency
            }
            accumulatedDelay += duration
        }
        
        let totalDuration = frequencies.reduce(0) { $0 + $1.duration }
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) { [weak self] in
            self?.stopPlayback()
        }
    }
    
    func toggleLeftChannel(isActive: Bool) {
        leftGain = isActive ? 1.0 : 0.0
        updatePanning()
    }
    
    func toggleRightChannel(isActive: Bool) {
        rightGain = isActive ? 1.0 : 0.0
        updatePanning()
    }
    
    private func updatePanning() {
        switch currentMode {
        case .wavFile:
            guard let wavPlayerNode = wavPlayerNode else { return }
            wavPlayerNode.volume = 1.0
            
            if leftGain == 0 && rightGain == 1.0 {
                wavPlayerNode.pan = 1.0
            } else if leftGain == 1.0 && rightGain == 0 {
                wavPlayerNode.pan = -1.0
            } else if leftGain == 1.0 && rightGain == 1.0 {
                wavPlayerNode.pan = 0.0
            } else if leftGain == 0 && rightGain == 0 {
                wavPlayerNode.volume = 0.0
            }
            
        case .sineWave:
            if leftGain == 0 && rightGain == 0 {
                stopPlayback()
            } else if isPlaying {
                let currentFreq = currentFrequency
                setupEngineIfNeeded(for: .sineWave)
                currentFrequency = currentFreq
                isPlaying = true
            }
            
        case .none:
            break
        }
    }
    
    func stopPlayback() {
        isPlaying = false
        resetEngine()
        try? AVAudioSession.sharedInstance().setActive(false)
        onPlaybackComplete?()
    }
    
    deinit {
        stopPlayback()
    }
}
