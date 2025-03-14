//
//  DBMeterViewModel.swift
//  WaterEject
//
//  Created by Talha on 14.03.2025.
//

import Foundation
import AVFoundation

class DBMeterViewModel: ObservableObject {
    @Published var decibels: Double = 0.0
    @Published var isRecording = false
    @Published var averageDB: Double = 0.0
    @Published var minDB: Double = 0.0
    @Published var maxDB: Double = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var dbValues: [Double] = []
    
    var gaugeValue: Double {
        // Convert dB value to gauge position (0.2 to 0.8 range)
        let minDB: Double = 0
        let maxDB: Double = 120
        let normalizedValue = (decibels - minDB) / (maxDB - minDB)
        return 0.2 + (normalizedValue * 0.6)
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("recording.wav")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            startMetering()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false
        
        // Reset values when stopping
        DispatchQueue.main.async {
            self.decibels = 0.0
            self.averageDB = 0.0
            self.minDB = 0.0
            self.maxDB = 0.0
            self.dbValues.removeAll()
        }
        
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    private func startMetering() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateMeters()
        }
    }
    
    private func updateMeters() {
        guard let recorder = audioRecorder else { return }
        
        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)
        let db = powf(10, averagePower / 20)
        let normalizedDB = Double(db) * 120
        
        DispatchQueue.main.async {
            self.decibels = normalizedDB
            self.dbValues.append(normalizedDB)
            
            // Update statistics
            self.averageDB = self.dbValues.reduce(0, +) / Double(self.dbValues.count)
            self.minDB = self.dbValues.min() ?? 0
            self.maxDB = self.dbValues.max() ?? 0
        }
    }
    
    deinit {
        stopRecording()
    }
}
