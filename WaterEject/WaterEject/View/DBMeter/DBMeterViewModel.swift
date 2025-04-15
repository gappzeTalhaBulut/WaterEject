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
    private let appStorage = AppStorageManager()
    private let paywallRepository = PaywallRepository.shared
    private var premiumCheckTimer: Timer?
    
    deinit {
        print("DBMeterViewModel deinit called")
        cleanupResources()
    }
    
    // MARK: - Private cleanup method
    private func cleanupResources() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        premiumCheckTimer?.invalidate()
        premiumCheckTimer = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    var gaugeValue: Double {
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
            
            premiumCheckTimer?.invalidate()
            premiumCheckTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.checkPremiumAndContinue()
            }
            
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        print("stopRecording called")
        cleanupResources()
        
        // Reset values synchronously on the current thread
        resetValues()
    }
    
    // MARK: - Private reset method
    private func resetValues() {
        isRecording = false
        decibels = 0.0
        averageDB = 0.0
        minDB = 0.0
        maxDB = 0.0
        dbValues.removeAll()
    }
    
    private func checkPremiumAndContinue() {
        if !appStorage.isPremium {
            stopRecording()
            Task { [weak self] in
                await self?.showPaywallForUser()
            }
        }
    }
    
    private func showPaywallForUser() async {
        await paywallRepository.openPaywallIfEnabled(
            action: .dbMeterAction,
            isNotVisibleAction: nil,
            onCloseAction: nil,
            willOpenADS: nil,
            onPurchaseSuccess: { [weak self] in
                self?.startRecording()
            },
            onRestoreSuccess: { [weak self] in
                self?.startRecording()
            }
        )
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.decibels = normalizedDB
            self.dbValues.append(normalizedDB)
            
            self.averageDB = self.dbValues.reduce(0, +) / Double(self.dbValues.count)
            self.minDB = self.dbValues.min() ?? 0
            self.maxDB = self.dbValues.max() ?? 0
        }
    }
}
